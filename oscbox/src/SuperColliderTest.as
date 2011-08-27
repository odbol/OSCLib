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
package
{
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.relivethefuture.osc.core.OscMessage;
	import com.relivethefuture.osc.supercollider.Server;
	import com.relivethefuture.osc.supercollider.data.GroupTree;
	import com.relivethefuture.osc.supercollider.data.ServerStatus;
	import com.relivethefuture.osc.supercollider.events.SCEvent;
	import com.relivethefuture.sc.ui.ServerStatusView;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.goasap.GoEngine;
	import org.goasap.interfaces.IUpdatable;
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;
	
	public class SuperColliderTest extends Sprite implements IUpdatable
	{
		private static const log:Logger = LogContext.getLogger(SuperColliderTest);
		
		private static var HOST:String = "127.0.0.1";
		private static var PORT:int = 57210;
		
		private var server:Server;
		
		private var connectButton:PushButton;    	
		
		private var loadSynthButton:PushButton;
		private var createSynthButton:PushButton;
		private var killSynthButton:PushButton;
		private var setFreqButton:PushButton;
		private var groupQuery:PushButton;
		private var groupInput:InputText;
		
		private var serverStatus:ServerStatus;
		private var serverStatusView:ServerStatusView;
		
		private var groupTree:GroupTree;
		
		private var getStatusMessage:OscMessage;
		
		public function SuperColliderTest()
		{
			server = new Server(HOST, PORT);
			server.addEventListener(SCEvent.CONNECTED,connected);
			
            serverStatusView = new ServerStatusView();
            serverStatusView.setStatusData(server.getStatusModel());
        	addChild(serverStatusView);    
            serverStatusView.x = 300;
            
            //connectButton = new PushButton(this,0,0,"CONNECT",connectToServer);
            loadSynthButton = new PushButton(this,0,90,"Load Synth Def",loadSynthDef);
            createSynthButton = new PushButton(this,0,120,"Create synth",createSynth);
            killSynthButton = new PushButton(this,0,150,"Kill Synth",killSynth);
            setFreqButton = new PushButton(this,0,180,"Set Freq",setFreq);
            groupQuery = new PushButton(this,0,210,"Group Query", queryGroup);
            groupInput = new InputText(this,150,210,"0");
            
            groupTree = new GroupTree();
            
            server.connect();
            
            //dispatcher.registerHandler("/g_queryTree.reply",groupTree);
            
		}
	
		private function connected(event:SCEvent):void
		{
			GoEngine.addItem(this);
		}
		
		private function queryGroup(event:Event):void
		{
           var msg:OscMessage = new OscMessage("/g_queryTree",parseInt(groupInput.text),0);
           server.sendMessage(msg);			
		}
		
		private function loadSynthDef(event:Event):void
		{
           var msg:OscMessage = new OscMessage("/d_load","sine");
           server.sendMessage(msg);			
		}
       	
       	private function killSynth(event:Event):void
       	{
           var msg:OscMessage = new OscMessage("/n_free",-1);
           server.sendMessage(msg);
       	}
       	
       	private function createSynth(event:Event):void
       	{
//			/s_new      create a new synth
//			string - synth definition name
//			int - synth ID
//			int - add action (0,1,2, 3 or 4 see below)
//			int - add target ID
//			[
//				int or string - a control index or name
//				float - a control value
//			] * N
//			
           var msg:OscMessage = new OscMessage("/s_new","sine",-1,1,0);
           server.sendMessage(msg);
       	}
       	
       	private function setFreq(event:Event):void
       	{
			//s.sendMsg("/n_set", x, "freq", 800);
			var freq:Number = (Math.random() * 400) + 100;
			var msg:OscMessage = new OscMessage("/n_set",-1,"freq",freq);
       		server.sendMessage(msg);
       	}
       	        
		public function get pulseInterval():int
		{
			return 500;
		}
		
		public function update(time:Number):void
		{
			server.getStatus();
		}        
	}
}