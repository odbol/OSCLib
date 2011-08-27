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


package {
    import com.bit101.components.PushButton;
    import com.relivethefuture.osc.core.IOscListener;
    import com.relivethefuture.osc.core.OscBundle;
    import com.relivethefuture.osc.core.OscClient;
    import com.relivethefuture.osc.core.OscMessage;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    
    public class OSCProtocolTest extends Sprite implements IOscListener
    {
    	private var oscPort:OscClient;
    	
    	private var charCode:int = 65;

		private var connectButton:PushButton;    	
    	private var addPacketButton:PushButton;
    	private var flushButton:PushButton;
    	
        public function OSCProtocolTest() 
        {
        	trace("Running test");
            oscPort = new OscClient("localhost", 4444);
            oscPort.addEventListener(Event.CONNECT,connected);
            oscPort.addEventListener(IOErrorEvent.IO_ERROR,ioError);
            oscPort.addOscListener(this);
            connectButton = new PushButton(this,0,0,"CONNECT",connectToServer);
            addPacketButton = new PushButton(this,0,30,"ADD PACKET",addPacket);
            flushButton = new PushButton(this,0,60,"FLUSH",flushBuffer);
        }
        
        private function ioError(event:IOErrorEvent):void
        {
        	trace("IO Error : " + event.text);
        }
        
        private function connectToServer(event:Event):void
        {
        	if(!oscPort.connected)
        	{
        		oscPort.connect("localhost",4444);
        	}
        	else
        	{
        		trace("Already connected");
        	}
        }
        
        private function flushBuffer(event:Event):void
        {
        	oscPort.flush();
        }
        
        private function addPacket(event:Event):void
        {
            var msg:OscMessage = new OscMessage("/box/" + String.fromCharCode(charCode++));
            msg.addArgument("STRINGY");
            msg.addArgument(23);
            oscPort.sendPacket(msg);
        }
        
        public function handleBundle(bundle:OscBundle):void
        {
        	trace("Bundle Received : " + bundle.getPackets().length);
        }
        
        public function handleMessage(msg:OscMessage):void
        {
       		trace("Message Received: " + msg.getAddress() + " : " + msg.getArguments().length);
        }
        
        private function connected(event:Event):void
        {
        	trace("CONNECTED");
        }
    }
}
