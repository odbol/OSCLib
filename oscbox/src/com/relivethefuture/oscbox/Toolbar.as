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
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	public class Toolbar extends Sprite
	{
		private var items:Dictionary;
		private var panel:Panel;
		
		private var itemSize:uint = 30;
		
		public function Toolbar()
		{
			super();
			items = new Dictionary();
			
			panel = new Panel(this);
			panel.height = 38;
		}
		
		public function addItem(itemName:String,actionHandler:Function):void
		{
			var item:PushButton = new PushButton(panel);
			item.label = itemName;
			item.width = itemSize;
			item.height = 30;
			items[item] = actionHandler;
			item.addEventListener(MouseEvent.CLICK,actionHandler);
			
			draw();	
		}
		
		private function draw():void
		{
			var x:uint = 0;
			
			for(var item:Object in items)
			{
				item.x = x + 4;
				item.y = 4;
				item.width = itemSize;
				item.height = itemSize;
				x += itemSize;	
			}
			
			panel.width = x + 8;
		}
	}
}