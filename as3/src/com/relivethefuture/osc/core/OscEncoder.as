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
	import flash.utils.IDataOutput;
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;

	/**
	 * Converts Actionscript objects into OSC binary data.
	 *
	 * <p>The encoder will write data to any implementor of <code>IDataOutput</code> such
	 * as a <code>Socket</code> or a <code>ByteArray</code></p>
	 *
	 * @see http://opensoundcontrol.org/spec-1_0
	 */
	public class OscEncoder {
		private static const log:Logger=LogContext.getLogger(OscEncoder);

		public var writePacketSize:Boolean = false;
		
		public function OscEncoder(writePacketSize:Boolean = false) {
			this.writePacketSize = writePacketSize;
		}

		/**
		 * Encode an OSC Packet into a ByteArray.
		 *
		 * @param	packet		OscPacket : Either a message or a bundle
		 * @param	byffer		where to write the binary data
		 */
		public function encode(packet:OscPacket, buffer:IDataOutput):int {
			if(writePacketSize) {
				var size:int=packet.getSize();
				buffer.writeInt(size);
			}

			if (packet.isBundle()) {
				encodeBundle(OscBundle(packet), buffer);
			} else {
				encodeMessage(OscMessage(packet), buffer);
			}

			return size;
		}

		/**
		 * Convert an <code>OscBundle</code> and its enclosed packets
		 * into binary and write it to the supplied output.
		 *
		 * @param	msg		an OSC bundle
		 * @param	buffer	where to write the binary data
		 */
		private function encodeBundle(bundle:OscBundle, buffer:IDataOutput):void {
			writeString(OscBundle.BUNDLE_HEADER, buffer);

			writeTimestamp(bundle.getTimestamp(), buffer);

			var packets:Array=bundle.getPackets();
			for (var i:int=0; i < packets.length; i++) {
				var packet:OscPacket=packets[i];
				// Only add valid packets
				if (packet.isValid()) {
					encode(packet, buffer);
				}
			}
		}

		/**
		 * Convert an actionscript Data object into the OSC timestamp format (see above).
		 *
		 * @param	timestamp	a date
		 * @param	buffer		where to write the binary data
		 */
		private function writeTimestamp(timestamp:Date, buffer:IDataOutput):void {
			if ((timestamp == null) || (timestamp == OscBundle.IMMEDIATELY)) {
				buffer.writeInt(0);
				buffer.writeInt(1);
			} else {
				var milliseconds:Number=timestamp.getTime();
				var secondsSinceEpoch:Number=(milliseconds / 1000);
				var seconds:Number=secondsSinceEpoch + OscBundle.SECONDS_TO_EPOCH;
				var fraction:Number=((milliseconds % 1000) * 0x100000000) / 1000;

				buffer.writeInt(seconds);
				buffer.writeInt(fraction);
			}
		}

		/**
		 * Convert an <code>OscMessage</code> into binary and write it to the supplied
		 * output.
		 *
		 * @param	msg		an OSC message
		 * @param	buffer	where to write the binary data
		 */
		private function encodeMessage(msg:OscMessage, buffer:IDataOutput):void {
			var addr:String = msg.getAddress();
			writeString(addr, buffer);

			var typeTags:String = msg.getTypeTags();
			writeString(typeTags, buffer);

			var args:Array = msg.getArguments();
			for (var i:int=0; i < args.length; i++) {
				var arg:* = args[i];
				write(arg, buffer);
			}
		}

		/**
		 * Write a string to the byte stream and pad with null bytes as necessary.
		 *
		 * <p>Strings are always null terminated, but the data length must also be
		 * 4-byte aligned.</p>
		 *
		 * <p>So a string of "doom" actually requires 8 bytes.</p>
		 * <p>One null to terminate the string and 3 for alignment.</p>
		 *
		 * @param	s		the string to write to the buffer
		 * @param	buffer	where to write the binary data
		 */
		private function writeString(s:String, buffer:IDataOutput):void {
			if (log.isDebugEnabled())
				log.debug("Write String " + s);

			buffer.writeUTFBytes(s);

			var mod:int = s.length % 4;
			var pad:int = 4 - mod;

			for (var i:int=0; i < pad; i++) {
				buffer.writeByte(0);
			}
		}

		/**
		 * Write a data item to the output.
		 *
		 * <p>Currently only supports String, int, uint and Number</p>
		 * <p>int and uint are written as OSC int type<p>
		 * <p>Numbers are written as OSC float type</p>
		 *
		 * @param	item	the data to write
		 * @param	buffer	where to write the binary data
		 */
		private function write(item:*, buffer:IDataOutput):void {
			if (log.isDebugEnabled())
				log.debug("Write Item " + item);

			if (item is String) {
				writeString(item, buffer);
			} else if (item is int) {
				buffer.writeInt(item as int);
			} else if (item is uint) {
				buffer.writeInt(item as int);
			} else if (item is Number) {
				buffer.writeFloat(item as Number);
			} else {
				log.warn("Unknown item type " + typeof(item));
			}
		}
		
	}
}