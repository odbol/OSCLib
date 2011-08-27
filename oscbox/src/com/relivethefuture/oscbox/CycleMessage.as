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
package com.relivethefuture.oscbox
{
	import com.relivethefuture.osc.core.OscClient;
	import com.relivethefuture.osc.core.OscMessage;
	
	import org.goasap.events.GoEvent;
	import org.goasap.items.LinearGo;

	public class CycleMessage extends OscMessage
	{
		private var _generator:LinearGo;
		private var client:OscClient;
		private var size:int;
		
		private var active:Boolean = false;
		
		public function CycleMessage(generator:LinearGo, address:String = "/cycle",id:int = 0)
		{
			super();

			args[0] = id;			
			typeTags = ",i";
			setGenerator(generator);
			setAddress(address);
		}


		public function setActive(a:Boolean):void
		{
			trace("Set Active : " + a);
			active = a;
		}
				
		public function setClient(client:OscClient):void
		{
			this.client = client;
		}

		public function set id(id:int):void
		{
			args[0] = id;
		}
		
		public function setGenerator(generator:LinearGo):void
		{
			if(_generator != null)
			{
				_generator.removeEventListener(GoEvent.CYCLE,cycle);
			}
			_generator = generator;
			_generator.addEventListener(GoEvent.CYCLE,cycle);
		}
		
		private function cycle(event:GoEvent):void
		{
			if(client != null && active)
			{
				client.sendPacket(this);
			}			
		}
		
		override public function setAddress(newAddress:String):void
		{
			address = newAddress;

			// Size is address plus 8 bytes 
			// typeTags : 4
			// id : 4
			size = getStringSize(address) + 8;
		}
		
		override public function getSize():int
		{
			return size;
		}		
	}
}