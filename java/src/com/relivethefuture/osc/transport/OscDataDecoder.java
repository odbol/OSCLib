/**
 * Copyright (c) 2008 Martin Wood-Mitrovski
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.relivethefuture.osc.transport;

import java.math.BigInteger;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.util.Date;

import org.apache.mina.core.session.IoSession;
import org.apache.mina.core.buffer.IoBuffer;
import org.apache.mina.filter.codec.CumulativeProtocolDecoder;
import org.apache.mina.filter.codec.ProtocolDecoderOutput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.relivethefuture.osc.data.OscBundle;
import com.relivethefuture.osc.data.OscMessage;
import com.relivethefuture.osc.data.OscPacket;
import com.relivethefuture.osc.data.OscPacketFactory;

/*
 OSC Type Tag  	Type of corresponding argument
 i  int32
 f 	float32
 s 	OSC-string
 b 	OSC-blob
 h 	64 bit big-endian two's complement integer
 t 	OSC-timetag
 d 	64 bit ("double") IEEE 754 floating point number
 S 	Alternate type represented as an OSC-string (for example, for systems that differentiate "symbols" from "strings")
 c 	an ascii character, sent as 32 bits
 r 	32 bit RGBA color
 m 	4 byte MIDI message. Bytes from MSB to LSB are: port id, status byte, data1, data2
 T 	True. No bytes are allocated in the argument data.
 F 	False. No bytes are allocated in the argument data.
 N 	Nil. No bytes are allocated in the argument data.
 I 	Infinitum. No bytes are allocated in the argument data.
 [ 	Indicates the beginning of an array. The tags following are for data in the Array until a close brace tag is reached.
 ] 	Indicates the end of an array.
 */

public class OscDataDecoder extends CumulativeProtocolDecoder {
	final Logger logger = LoggerFactory.getLogger(OscDataDecoder.class);

	private static CharsetDecoder csd = Charset.forName("UTF-8").newDecoder();

	private OscPacketFactory packetFactory;

	private Boolean udp;

	public OscDataDecoder(OscPacketFactory factory, Boolean isUDP) {
		packetFactory = factory;
		udp = isUDP;
	}

	@Override
	protected boolean doDecode(IoSession session, IoBuffer in,
			ProtocolDecoderOutput out) throws Exception {
		if (udp || in.prefixedDataAvailable(4)) {
			out.write(decodePacket(in));
			return true;
		} else {
			in.mark();
			logger.debug("Waiting for more data : " + in.getInt());
			in.reset();
			return false;
		}

	}

	private OscPacket decodePacket(IoBuffer in) throws CharacterCodingException {
		String typeOrAddress = readString(in);

		logger.debug("Message Type : " + typeOrAddress);

		if (typeOrAddress.startsWith(OscBundle.BUNDLE_HEADER)) {
			return convertBundle(in);
		} else {
			return convertMessage(typeOrAddress, in);
		}
	}

	/**
	 * Convert the byte array a bundle. Assumes that the byte array is a bundle.
	 * 
	 * @return a bundle containing the data specified in the byte stream
	 * @throws CharacterCodingException
	 */
	private OscBundle convertBundle(IoBuffer buffer)
			throws CharacterCodingException {
		Date timestamp = readTimeTag(buffer);
		logger.debug("Bundle at " + timestamp);

		OscBundle bundle = packetFactory.createBundle();
		bundle.setTimestamp(timestamp);

		while (buffer.hasRemaining()) {
			int packetLength = buffer.getInt();
			logger.debug("Packet size : " + packetLength);
			OscPacket packet = decodePacket(buffer);
			logger.debug("Added packet : " + packet.isBundle());
			bundle.addPacket(packet);
		}
		return bundle;
	}

	/**
	 * Convert the byte array a simple message. Assumes that the byte array is a
	 * message.
	 * 
	 * @return a message containing the data specified in the byte stream
	 * @throws CharacterCodingException
	 */
	private OscMessage convertMessage(String address, IoBuffer buffer)
			throws CharacterCodingException {
		OscMessage message = packetFactory.createMessage();
		message.setAddress(address);

		String types = readString(buffer);

		if (types == null || types.length() == 0) {
			// we are done
			return message;
		} else {
			logger.debug("Message types : " + types);
			// Dont need the comma at the start
			types = types.substring(1);
		}

		// Skip first char is it should be a comma
		for (int i = 0; i < types.length(); ++i) {
			char type = types.charAt(i);

			if ('[' == type) {
				int closePos = types.indexOf(']', i + 1);

				// Get the type string for the array
				String typesInArray = types.substring(i + 1, closePos);

				// Make a new array for the decoded data
				Object[] array = new Object[typesInArray.length()];
				for (int j = 0; j < array.length; j++) {
					array[j] = readArgument(typesInArray.charAt(j), buffer);
				}
				message.addArgument(array, typesInArray);
				// move to end of array section
				i = closePos;
			} else {
				decodeArgument(message, type, buffer);
			}
		}
		return message;
	}

	/**
	 * Read a string from the byte stream.
	 * 
	 * @return the next string in the byte stream
	 * @throws CharacterCodingException
	 */
	private String readString(IoBuffer buffer) throws CharacterCodingException {
		logger.debug("Pre String : " + buffer.position());
		String str = buffer.getString(csd);
		logger.debug("Post String : " + buffer.position());
		logger.debug("String length : " + str.length());
		int pad = (str.length() + 1) % 4;
		if (pad > 0) {
			logger.debug("Skip " + pad);
			buffer.skip(4 - pad);
		}
		logger.debug("Post skip " + buffer.position());
		return str;
	}

	/**
	 * Read an object of the type specified by the type char.
	 * 
	 * @param c
	 *            type of argument to read
	 * @return an Object
	 * @throws CharacterCodingException
	 */
	private Object readArgument(char c, IoBuffer buffer)
			throws CharacterCodingException {
		logger.debug("Read Arg " + c + " : " + buffer.position() + " : "
				+ buffer.limit());
		switch (c) {
		case 'i':
			return buffer.getInt();
		case 'h':
			return BigInteger.valueOf(buffer.getLong());
		case 'f':
			return buffer.getFloat();
		case 'd':
			return buffer.getDouble();
		case 's':
		case 'S':
			return readString(buffer);
		case 'c':
			return (char) buffer.getInt();
		case 'T':
			return Boolean.TRUE;
		case 'F':
			return Boolean.FALSE;
		case 'b':
			return readBlob(buffer);
		}

		return null;
	}

	private void decodeArgument(OscMessage message, char c, IoBuffer buffer)
			throws CharacterCodingException {
		logger.debug("Read Arg " + c + " : " + buffer.position() + " : "
				+ buffer.limit());

		switch (c) {
		case 'i':
			message.addArgument(buffer.getInt());
			break;
		case 'h':
			message.addArgument(BigInteger.valueOf(buffer.getLong()));
			break;
		case 'f':
			message.addArgument(buffer.getFloat());
			break;
		case 'd':
			message.addArgument(buffer.getDouble());
			break;
		case 's':
		case 'S':
			message.addArgument(readString(buffer));
			break;
		case 'c':
			message.addArgument((char) buffer.getInt());
			break;
		case 'T':
			message.addArgument(Boolean.TRUE);
			break;
		case 'F':
			message.addArgument(Boolean.FALSE);
			break;
		case 'b':
			message.addArgument(readBlob(buffer));
			break;
		}
	}

	private Object readBlob(IoBuffer buffer) {
		int size = buffer.getInt();
		byte[] data = new byte[size];
		buffer.get(data);
		return data;
	}

	/**
	 * Read the time tag and convert it to a Java Date object. A timestamp is a
	 * 64 bit number representing the time in NTP format. The first 32 bits are
	 * seconds since 1900, the second 32 bits are fractions of a second.
	 * 
	 * @return a Date
	 */
	private Date readTimeTag(IoBuffer buffer) {
		byte[] secondBytes = new byte[8];
		byte[] fractionBytes = new byte[8];
		for (int i = 0; i < 4; i++) {
			// clear the higher order 4 bytes
			secondBytes[i] = 0;
			fractionBytes[i] = 0;
		}
		// while reading in the seconds & fraction, check if
		// this timetag has immediate semantics
		boolean isImmediate = true;
		for (int i = 4; i < 8; i++) {
			secondBytes[i] = buffer.get();
			if (secondBytes[i] > 0)
				isImmediate = false;
		}
		for (int i = 4; i < 8; i++) {
			fractionBytes[i] = buffer.get();
			if (i < 7) {
				if (fractionBytes[i] > 0)
					isImmediate = false;
			} else {
				if (fractionBytes[i] > 1)
					isImmediate = false;
			}
		}

		if (isImmediate) {
			return OscBundle.IMMEDIATELY;
		}

		BigInteger secondsFrom1900 = new BigInteger(secondBytes);
		long secondsFromEpoch = secondsFrom1900.longValue()
				- OscBundle.SECONDS_TO_EPOCH.longValue();
		if (secondsFromEpoch < 0)
			secondsFromEpoch = 0; // no point maintaining
		// times in the distant past
		long fraction = (new BigInteger(fractionBytes).longValue());
		// the next line was cribbed from jakarta commons-net's NTP TimeStamp
		// code
		fraction = (fraction * 1000) / 0x100000000L;
		// I don't where, but I'm losing 1ms somewhere...
		fraction = (fraction > 0) ? fraction + 1 : 0;
		long millisecs = (secondsFromEpoch * 1000) + fraction;
		return new Date(millisecs);
	}
}
