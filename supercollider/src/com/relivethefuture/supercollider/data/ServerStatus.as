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
package com.relivethefuture.supercollider.data
{
	import com.relivethefuture.osc.core.IMessageListener;
	import com.relivethefuture.osc.core.OscMessage;
	import com.relivethefuture.supercollider.events.SCEvent;
	
	import flash.events.EventDispatcher;
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;

	[Event(name="serverStatus",type="SCEvent")]
	public class ServerStatus extends EventDispatcher implements IMessageListener
	{
		private static const log:Logger = LogContext.getLogger(ServerStatus);
		
		public var ugenCount:int;
		public var synthCount:int;
		public var groupCount:int;
		public var loadedSynthDefCount:int;
		public var averageCPU:Number;
		public var peakCPU:Number;
		public var nominalSampleRate:Number;
		public var actualSampleRate:Number;
		
		public function ServerStatus()
		{
		}

		public function handleMessage(message:OscMessage):void
		{
        	var args:Array = message.getArguments();
			//int - 1. unused.
			
			//int - number of unit generators.
			ugenCount = args[1];
			
			//int - number of synths.
			synthCount = args[2];
						
			//int - number of groups.
			groupCount = args[3];
						
			//int - number of loaded synth definitions.
			loadedSynthDefCount = args[4];
						
			//float - average percent CPU usage for signal processing
			averageCPU = args[5];
						
			//float - peak percent CPU usage for signal processing
			peakCPU = args[6];
			
			//double - nominal sample rate
			nominalSampleRate = args[7];
						
			//double - actual sample rate
			actualSampleRate = args[8];
			
			dispatchEvent(new SCEvent(SCEvent.SERVER_STATUS));
		}
		
		override public function toString():String
		{
			return 	"UGens : " + ugenCount + "\n" +
					"Synths : " + synthCount + "\n" +
					"Groups : " + groupCount + "\n" +
					"SynthDefs : " + loadedSynthDefCount + "\n" +
					"Avg CPU : " + averageCPU + "\n" +
					"Peak CPU : " + peakCPU + "\n" +
					"Nominal SR : " + nominalSampleRate + "\n" +
					"Actual SR : " + actualSampleRate + "\n";
		}
	}
}