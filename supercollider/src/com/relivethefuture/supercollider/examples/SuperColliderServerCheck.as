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


package com.relivethefuture.supercollider.examples
{
	import com.relivethefuture.supercollider.Server;
	import com.relivethefuture.supercollider.events.SCEvent;
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;
	
	public class SuperColliderServerCheck
	{
		private static const log:Logger = LogContext.getLogger(SuperColliderServerCheck);
		
		private var server:Server;
		
		public function SuperColliderServerCheck()
		{
			server = new Server();
			
			server.addEventListener(SCEvent.CONNECTED,connected);
			server.addStatusListener(statusReceived);
			server.connect();
		}

		private function connected(event:SCEvent):void
		{
			server.getStatus();
		}
		
		private function statusReceived(event:SCEvent):void
		{
			log.info("Status : " + server.getStatusModel().toString());
		}
	}
}