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
import java.nio.charset.CharsetEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;

import org.apache.mina.core.buffer.IoBuffer;
import org.apache.mina.core.session.IoSession;
import org.apache.mina.filter.codec.ProtocolEncoder;
import org.apache.mina.filter.codec.ProtocolEncoderOutput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.relivethefuture.osc.data.OscBundle;
import com.relivethefuture.osc.data.OscMessage;
import com.relivethefuture.osc.data.OscPacket;

public class OscDataEncoder implements ProtocolEncoder {
	final Logger logger = LoggerFactory.getLogger(OscDataEncoder.class);

	private static CharsetEncoder cse = Charset.forName("UTF-8").newEncoder();

	private boolean udp = false;

	public OscDataEncoder(Boolean isUDP) {
		udp = isUDP;
	}

	public void dispose(final IoSession arg0) throws Exception {
	}

	public void encode(IoSession session, Object message,
			ProtocolEncoderOutput out) throws Exception {
		OscPacket packet = (OscPacket) message;

		if (!packet.isValid()) {
			throw new PacketNotValidException();
		}

		int packetSize = packet.getSize();

		IoBuffer buffer = IoBuffer.allocate(packetSize + 4);
		// buffer.setAutoExpand(true);

		encodePacket(packet, buffer, !udp);

		buffer.flip();
		out.write(buffer);
	}

	/**
	 * Write an OscPacket into a data buffer.
	 * 
	 * For HTTP transmission set the writeSize flag to true so that the size of
	 * the packet is written before the data.
	 * 
	 * @param packet
	 *            An OSC Packet
	 * @param buffer
	 *            The buffer to write into
	 * @param writeSize
	 *            Whether to send the size of the data packet before the data
	 *            itself.
	 * @throws CharacterCodingException
	 */
	public void encodePacket(OscPacket packet, IoBuffer buffer,
			boolean writeSize) throws CharacterCodingException {
		logger.debug("Encode Packet : " + packet.isBundle() + " : "
				+ packet.isValid());

		if (writeSize) {
			buffer.putInt(packet.getSize());
		}

		if (packet.isBundle()) {
			encodeBundle((OscBundle) packet, buffer);
		} else {
			encodeMessage((OscMessage) packet, buffer);
		}
	}

	/**
	 * Write an OSC bundle to a buffer.
	 * 
	 * @param bundle
	 *            An OSC Bundle
	 * @param buffer
	 *            The buffer to write into
	 * @throws CharacterCodingException
	 */
	private void encodeBundle(OscBundle bundle, IoBuffer buffer)
			throws CharacterCodingException {
		write(OscBundle.BUNDLE_HEADER, buffer);

		writeTimestamp(bundle.getTimestamp(), buffer);

		for (Iterator<OscPacket> i = bundle.getPackets().iterator(); i
				.hasNext();) {
			OscPacket packet = (OscPacket) i.next();
			// Only add valid packets
			if (packet.isValid()) {
				// Packets inside a bundle have to include their size
				encodePacket(packet, buffer, true);
			}
		}
	}

	private void writeTimestamp(Date timestamp, IoBuffer buffer) {
		if ((timestamp == null) || (timestamp == OscBundle.IMMEDIATELY)) {
			buffer.putInt(0);
			buffer.putInt(1);
		} else {
			long milliseconds = timestamp.getTime();
			long secondsSinceEpoch = (long) (milliseconds / 1000);
			long seconds = secondsSinceEpoch
					+ OscBundle.SECONDS_TO_EPOCH.longValue();
			long fraction = ((milliseconds % 1000) * 0x100000000L) / 1000;

			buffer.putInt((int) seconds);
			buffer.putInt((int) fraction);
		}
	}

	/**
	 * Write and OSC Message into a buffer
	 * 
	 * @param message
	 * @param buffer
	 * @throws CharacterCodingException
	 */
	private void encodeMessage(OscMessage message, IoBuffer buffer)
			throws CharacterCodingException {
		String addr = message.getAddress();

		write(addr, buffer);

		ArrayList<Object> args = message.getArguments();

		String typeTags = message.getTypeTags();

		write(typeTags, buffer);

		for (Iterator<Object> i = args.iterator(); i.hasNext();) {
			Object arg = (Object) i.next();
			write(arg, buffer);
		}
	}

	private void write(Object arg, IoBuffer buffer)
			throws CharacterCodingException {
		if (arg == null) {
			logger.info("Cant add null argument");
			return;
		}

		if (arg instanceof byte[]) {
			byte[] bytes = (byte[]) arg;
			buffer.put(bytes);
			padBuffer(bytes.length, buffer);
			return;
		}

		if (arg instanceof Object[]) {
			Object[] theArray = (Object[]) arg;
			for (int i = 0; i < theArray.length; ++i) {
				write(theArray[i], buffer);
			}
			return;
		}

		if (arg instanceof Float) {
			buffer.putFloat((Float) arg);
			return;
		}

		if (arg instanceof String) {
			String str = (String) arg;
			write(str, buffer);
			return;
		}
		if (arg instanceof Integer) {
			buffer.putInt((Integer) arg);
			return;
		}

		if (arg instanceof BigInteger) {
			buffer.putLong(((BigInteger) arg).longValue());
			return;
		}
	}

	private void write(String s, IoBuffer buffer)
			throws CharacterCodingException {
		buffer.putString(s, cse);
		buffer.put((byte) 0);
		padBuffer(s.length() + 1, buffer);
	}

	private void padBuffer(int itemLength, IoBuffer buffer) {
		int mod = itemLength % 4;
		if (mod > 0) {
			byte[] padding = new byte[4 - mod];
			buffer.put(padding);
		}
	}
}
