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
	
	import flash.events.EventDispatcher;
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;

	public class GroupTree extends EventDispatcher implements IMessageListener
	{
		private static const log:Logger = LogContext.getLogger(GroupTree);
		
		public function GroupTree()
		{
			super();
		}
		
		public function handleMessage(message:OscMessage):void
		{
			var args:Array = message.getArguments();
			var includesControlValues:Boolean = args[0] == 1;
			
			//int - flag: if synth control values are included 1, else 0
			//int - node ID of the requested group
			if(log.isDebugEnabled()) log.debug("Group Tree Message. ID : " + args[1] + ". Message has " + args.length + " params");
			
			//int - number of child nodes contained within the requested group
			if(log.isDebugEnabled()) log.debug("Contains " + args[2] + " child nodes");
			if(log.isDebugEnabled()) log.debug("Control values are " + (includesControlValues ? "" : "not") + " included");
			
			var childNodeCount:uint = args[2];
			
			var currentNode:Node;
			
			var argIndex:uint = 3;
			
			while(childNodeCount-- > 0)
			{
				currentNode = new Node();

				//then for each node in the subtree:
				//[
				//	int - node ID
				currentNode.id = args[argIndex++];
				//	int - number of child nodes contained within this node. If -1this is a synth, if >=0 it's a group
				var numChildren:int = args[argIndex++];
				if(numChildren == -1)
				{ 
					//	then, if this node is a synth:
					//	symbol - the SynthDef name for this node.
					currentNode.name = args[argIndex++];
					
					//	then, if flag (see above) is true:
					if(includesControlValues)
					{
						var numControls:int = args[argIndex++];
						//	int - numControls for this synth (M)
						//	[
						while(numControls-- > 0)
						{
							//		symbol or int: control name or index
							var controlNameOrID:* = args[argIndex++];
							//		float or symbol: value or control bus mapping symbol (e.g. 'c1')
							var valueOrBusMapSymbol:* = args[argIndex++];
						}
						//	] * M
					}
				}
				else
				{
					// its a group
				}
				//] * the number of nodes in the subtree
			}			
		}
	}
}