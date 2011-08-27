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
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;
	
	/**
	 * Actionscript representation of an OSC Message.
	 * 
	 * <p>An OSC Message is composed of 3 basic pieces</p>
	 * 
	 * <ol>
	 * <li>Address 	: /foo/bar</li>
	 * <li>Type Tags : ,sif		(meaning a String, an Integer and a Float)</li>
	 * <li>Data		: Binary data in the order defined by the type tags</li>
	 * 
	 * <p>The <code>getSize</code> method allows you to find out how big this
	 * message will be when represented in the OSC binary format.</p>
	 */ 
	public class OscMessage implements OscPacket {
		private static const log:Logger = LogContext.getLogger(OscMessage);
		
		public static var DEBUG:Boolean = false;
		protected var address:String;
		protected var typeTags:String;
		protected var args:Array;
		
		private var datasize:int = 0;
		
		/**
		 * Create a new OscMessage using the optional supplied address
		 * and optional data parameters.
		 * 
		 * <code>var msg:OscMessage = new OscMessage("/foo/bar","test",12,3.4);</code>
		 * 
		 * @param	address		string address of the message
		 * @param	params		variable length arguments with message data
		 */
		public function OscMessage(address:String = "", ... params) {
			this.address = address;
			typeTags = ",";
			args = [];
			
		    for (var i:uint = 0; i < params.length; i++) {
		    	addArgument(params[i]);
		    }
		}
		
		/**
		 * Set the address of this message.
		 * 
		 * <code>setAddress("/foo/bar");</code>
		 * 
		 * @param	address	the address of the message
		 */
		public function setAddress(a:String):void {
			address = a;
		}
		
		/**
		 * Get the address of this message.
		 * 
		 * @returns	string address
		 */
		public function getAddress():String {
			return address;
		}
		
		/**
		 * Get the data arguments of this message.
		 * 
		 * @returns	an array of the data arguments
		 */
		public function getArguments():Array {
			return args;
		}
		
		/**
		 * Get the type tags for this message.
		 *  
		 * <p><b>Always starts with a comma</b></p>
		 * 
		 * <p>e.g. <code>,sif</code> means this message has String, Integer and Float data
		 * in that order</p>
		 *  
		 * @returns	type tag string
		 */
		public function getTypeTags():String {
			return typeTags;
		}
		
		/**
		 * Add an argument to this message.
		 * 
		 * @param	arg	The data to add to the message
		 */
		public function addArgument(arg:Object):void {
			if(log.isDebugEnabled()) log.debug("Add argument : " + arg + " : " + args);

			addType(arg);
			args.push(arg);
		}
		
		/**
		 * Add a typed actionscript object.
		 * 
		 * <p>Checks the type of supplied argument and updates the 
		 * type tag information and the data size.</p>
		 * 
		 * @param	type	the argument being added to the message
		 */
		private function addType(type:*):void {
			if(log.isDebugEnabled()) log.debug("Write Type : " + type.toString());
			
			if(type is String) {
				typeTags += 's';
				datasize += getStringSize(type as String);
			} else if(type is int) {
				typeTags += 'i';
				datasize += 4;
			} else if(type is uint) {
				typeTags += 'i';
				datasize += 4;
			} else if(type is Boolean) {
				// No data for booleans required.
				if(type as Boolean == true) {
					typeTags += 'T';
				} else {
					typeTags += 'F';
				}
			} else if(type is Number) {
				typeTags += 'f';
				datasize += 4;
			} else if(type is ByteArray) {
				var dataLength:int = (type as ByteArray).length;
				// OSC-blob
				typeTags += 'b';
				// An int32 size count,
				datasize += 4;
				// followed by that many 8-bit bytes of arbitrary binary data,
				datasize += dataLength;
				// followed by 0-3 additional zero bytes to make the total number of bits a multiple of 32.
				var mod:int = (dataLength % 4); 
				datasize += (mod > 0) ? 4 - mod : 0; 
			} else {
				log.warn("Unknown type " + typeof(type));
			}
		}
		
		/**
		 * Implementation of the <code>OscPacket</code> interface.
		 * 
		 * @returns	always returns false
		 */
		public function isBundle():Boolean {
			return false;
		}
		
		/**
		 * Does this message have the necessary pieces to be considered valid 
		 * (and therefore can be encoded into binary).
		 * 
		 * <p>The only required piece of information for an OSC message is the address.</p>
		 * 
		 * @returns	true if the message is ready for encoding. 
		 */
		public function isValid():Boolean {
			return address.length > 0;
		}
		
		/**
		 * How big this message is in OSC binary format.
		 * 
		 * @returns	size of message in bytes when encoded
		 */
		public function getSize():int {
			var addr:int = getStringSize(address);
			var type:int = getStringSize(typeTags);
			return addr + type + datasize;
		}
		
		/**
		 * The length of a string when encoded in the 4-byte aligned, padded
		 * OSC binary format.
		 * 
		 * @returns	string length with padding to be 4-byte aligned
		 */
		public function getStringSize(str:String):int {
			// Add 1 because a string must be zero terminated
			var strlen:int = str.length + 1;
			var mod:int = strlen % 4;
			var pad:int = (mod > 0) ? 4 - mod : 0;
			return strlen + pad;
		}
		
		public function toString():String {
			return address + " :: " + args.toString();
		}
	}
}