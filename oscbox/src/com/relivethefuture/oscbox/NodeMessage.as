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
	import com.relivethefuture.control.Node;
	import com.relivethefuture.events.ChangeEvent;
	import com.relivethefuture.osc.core.OscClient;
	import com.relivethefuture.osc.core.OscMessage;
	
	/**
	 * OSC Message for a single node.
	 * Automatically sends itself when the node changes
	 * 
	 * The packet has 3 arguments : ID x y
	 * ID : int
	 * x  : float
	 * y  : float
	 */
	public class NodeMessage extends OscMessage
	{
		private var _node:Node;
		
		private var size:int;
		
		private var client:OscClient;
		
		private var active:Boolean = false;
		
		public function NodeMessage(node:Node, address:String = "/node",id:int = 0)
		{
			super();

			trace("NodeMessage : " + address + " : " + id);
			
			args[0] = id;
			typeTags = ",iff";			
			setNode(node);
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
		
		public function setNode(newNode:Node):void
		{
			trace("SetNode : " + newNode);
			
			if(_node != null)
			{
				_node.removeEventListener(ChangeEvent.CHANGE,nodeChanged);
			}
			
			_node = newNode;
			_node.addEventListener(ChangeEvent.CHANGE,nodeChanged);
			
			args[1] = _node.x;
			args[2] = _node.y;
		}
		
		public function set id(id:int):void
		{
			args[0] = id;
		}
		
		private function nodeChanged(event:ChangeEvent):void
		{
			if(!active) return;
		
			args[1] = _node.x;
			args[2] = _node.y;
			if(client != null)
			{
				client.sendPacket(this);
			}
		}
		
		override public function setAddress(newAddress:String):void
		{
			address = newAddress;

			// Size is address plus 20 bytes 
			// typeTags : 8
			// id : 4
			// x : 4
			// y : 4
			size = getStringSize(address) + 20;
		}
		
		override public function getSize():int
		{
			return size;
		}
	}
}