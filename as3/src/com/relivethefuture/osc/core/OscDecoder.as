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
package com.relivethefuture.osc.core {
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;

	/**
	 * Converts binary OSC packets into Actionscript objects.
	 *
	 * <p>Converts binary OSC data into a <code>OscMessage</code> or an <code>OscBundle</code></p>
	 *
	 * <p>The decoder will convert data available from any implementation of <code>IDataInput</code>
	 * such as a <code>Socket</code> or a <code>ByteArray</code>.</p>
	 *
	 * <p>To decode your data create a decoder instance and call <code>decode(dataSource)</code>
	 * e.g.</p>
	 *
	 * <p><code>
	 * var d:Decoder = new OscDecoder();
	 * var s:Socket = new Socket();
	 * // get some data here
	 * d.decode(s);
	 * </code></p>
	 *
	 * <p>See the OSC Specification for more details about how OSC packets are defined.</p>
	 *
	 * @see http://opensoundcontrol.org/spec-1_0
	 * @author Martin Wood-Mitrovski
	 */
	public class OscDecoder {
		private static const logger:Logger = LogContext.getLogger(OscDecoder);
		
		public function OscDecoder() {
		}

		/**
		 * Convert input data into actionscript objects.
		 *
		 * <p>Decode the data available from the <code>IDataInput</code> source
		 * into an <code>OscMessage</code> or <code>OscBundle</code></p>
		 *
		 * <p>A bundle is easily identified as it starts with the string #bundle
		 * messages always start with the address</p>
		 *
		 * <p>Nested bundles are allowed.</p>
		 */
		public function decode(bytes:IDataInput):OscPacket {
			var typeOrAddress:String = readString(bytes);

			logger.debug("Message Type : " + typeOrAddress);

			if (typeOrAddress.indexOf(OscBundle.BUNDLE_HEADER) == 0) {
				return decodeBundle(bytes);
			} else {
				return decodeMessage(typeOrAddress, bytes);
			}
		}

		/**
		 * Convert input data into an <code>OscBundle</code>.
		 *
		 * @return a bundle containing the data specified in the byte stream
		 * @throws CharacterCodingException
		 */
		private function decodeBundle(buffer:IDataInput):OscBundle {
			var timestamp:Date = readTimeTag(buffer);
			// TODO : use Factory
			var bundle:OscBundle = new OscBundle(timestamp);

			while (buffer.bytesAvailable) {
				// recursively read through the stream and convert packets you find
				var packetLength:int = buffer.readInt();
				var packet:OscPacket = decode(buffer);
				bundle.addPacket(packet);
			}
			return bundle;
		}

		/**
		 * Convert the input data into an <code>OscMessage</code>.
		 *
		 * @return a message containing the data specified in the byte stream
		 * @throws CharacterCodingException
		 */
		private function decodeMessage(address:String, buffer:IDataInput):OscMessage {
			logger.debug("-- Decode Message : " + address + " : " + buffer.bytesAvailable.toString() + " --");
			var message:OscMessage = new OscMessage(address);
			var types:String = readString(buffer);

			logger.debug("Decoding message : " + address + " : " + types.length);

			if (types == null || types.length < 2) {
				// we are done
				return message;
			} else {
				logger.debug("Message types : " + types);
				// Dont need the comma at the start
				types = types.substring(1);
			}

			logger.debug("Processing types : " + types + " : " + types.length);

			// Skip first char is it should be a comma
			for (var i:int = 0; i < types.length; i++) {
				var type:String = types.charAt(i);

				logger.debug("TYPE : " + type + " : " + i);

				if ('[' == type) {
					var closePos:int = types.indexOf(']', i + 1);

					// Get the type string for the array
					var typesInArray:String = types.substring(i + 1, closePos);

					// Make a new array for the decoded data
					var args:Array = []
					for (var j:int = 0; j < typesInArray.length; j++) {
						args[j] = readArgument(typesInArray.charAt(j), buffer);
					}
					message.addArgument(args);
					// move to end of array section
					i = closePos;
				} else {
					message.addArgument(readArgument(type, buffer));
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
		private function readString(buffer:IDataInput):String {
			logger.debug("Read String : " + buffer.bytesAvailable);

			var strBuffer:ByteArray = new ByteArray();

			// Read buffer in chunks of 4 bytes and stop when a chunk ends with a null byte
			buffer.readBytes(strBuffer, 0, 4);
			var offset:int = 4;
			while (strBuffer[strBuffer.length - 1] != 0) {
				logger.debug("Read chunk : " + strBuffer.length);

				buffer.readBytes(strBuffer, offset, 4);
				offset += 4;
			}

			// Now scan backwards through the buffer to find last non-null byte
			var strLen:int = strBuffer.length - 1;
			for (var i:int = strBuffer.length - 1; i >= 0; i--) {
				if (strBuffer[i] != 0) {
					strLen = i;
					break;
				}
			}
			var str:String = strBuffer.toString().substr(0, strLen + 1);
			logger.debug("Read String : " + str + " : " + str.length);
			return str;
		}

		private function readArgument(c:String, buffer:IDataInput):* {
			switch (c) {
				case 'i':
					return buffer.readInt();
				case 'h':
					return buffer.readInt() + buffer.readInt();
				case 'f':
					return buffer.readFloat();
				case 'd':
					return buffer.readDouble();
				case 's':
				case 'S':
					return readString(buffer);
				case 'c':
					return buffer.readInt();
				case 'T':
					return true;
				case 'F':
					return false;
				case 'b':
					return readBlob(buffer);
			}

			return null;
		}

		private function readBlob(buffer:IDataInput):IDataInput {
			var size:int = buffer.readInt();
			var data:ByteArray = new ByteArray();
			data.readBytes(buffer as ByteArray, 0, size);
			return data;
		}

		/**
		 * Decode OSC time stamp information into an actionscript <code>Date</code>.
		 *
		 * <p>The Osc Specification 1.0 defines a time stamp as :</p>
		 *
		 * <p>Time tags are represented by a 64 bit fixed point number.
		 * The first 32 bits specify the number of seconds
		 * since midnight on January 1, 1900, and the last 32 bits
		 * specify fractional parts of a second to a precision of about 200 picoseconds.
		 * This is the representation used by Internet NTP timestamps.
		 * The time tag value consisting of 63 zero bits
		 * followed by a one in the least signifigant bit is a special case meaning "immediately."</p>
		 */
		private function readTimeTag(buffer:IDataInput):Date {
			var secondBytes:ByteArray = new ByteArray();
			var fractionBytes:ByteArray = new ByteArray();

			for (var i:int = 0; i < 4; i++) {
				// clear the top 4 bytes
				secondBytes[i] = 0;
				fractionBytes[i] = 0;
			}
			// check if this timetag is immediate
			var isImmediate:Boolean = true;
			for (i = 4; i < 8; i++) {
				secondBytes[i] = buffer.readByte();
				if (secondBytes[i] > 0) {
					isImmediate = false;
				}
			}
			for (i = 4; i < 8; i++) {
				fractionBytes[i] = buffer.readByte();
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

			var secondsFrom1900:Number = new Number(secondBytes);
			var secondsFromEpoch:Number = secondsFrom1900 - OscBundle.SECONDS_TO_EPOCH;
			if (secondsFromEpoch < 0) {
				secondsFromEpoch = 0;
			}

			var fraction:Number = new Number(fractionBytes);
			fraction = (fraction > 0) ? fraction + 1 : 0;
			var millisecs:Number = (secondsFromEpoch * 1000) + fraction;
			return new Date(millisecs);
		}
	}
}