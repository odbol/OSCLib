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
	import com.bit101.components.CheckBox;
	import com.bit101.components.InputText;
	import com.relivethefuture.osc.core.OscClient;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import org.goasap.items.LinearGo;

	public class OscCycleControl extends Sprite
	{
		private var message:CycleMessage;
		private var oscAddressField:InputText;
		private var activeCheckBox:CheckBox;

		public function OscCycleControl(generator:LinearGo,index:uint)
		{
			super();

			trace("OscCycleControl : " + generator + " : " + index);
			oscAddressField = new InputText(this,0,0,"/node",addressChanged);
			oscAddressField.addEventListener(FocusEvent.FOCUS_IN,textFieldSelected);
			oscAddressField.setSize(100,20);
			activeCheckBox = new CheckBox(this,110,3,"");
			activeCheckBox.addEventListener(MouseEvent.CLICK,activeSelected);
			
			message = new CycleMessage(generator,"/cycle",index);
			
		}
		
		public function setAddress(address:String):void
		{
			oscAddressField.text = address;
			message.setAddress(address);
		}
		
		public function getMessage():CycleMessage
		{
			return message;
		}
		
		private function addressChanged(event:Event):void
		{
			if(oscAddressField.text.length > 1)
			{
				message.setAddress(oscAddressField.text);
			}
		}
		public function setClient(c:OscClient):void
		{
			message.setClient(c);
		}
		
		private function activeSelected(event:Event):void
		{
			message.setActive(activeCheckBox.selected);	
		}
		
		private function textFieldSelected(event:FocusEvent):void
		{
			var e:Event = new Event(Event.SELECT);
			dispatchEvent(e);
		}
		
	}
}