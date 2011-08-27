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
	import com.relivethefuture.components.NodeBox;
	import com.relivethefuture.components.PathBox;
	import com.relivethefuture.control.Path;
	import com.relivethefuture.osc.core.OscClient;
	
	public class PathBoxNodeManager extends OscNodeManager
	{
		private var path:Path;
		private var positionNodeControl:OscNodeControl;
		private var cycleControl:OscCycleControl;
		
		public function PathBoxNodeManager(nb:NodeBox, client:OscClient)
		{
			super(nb, client);
			
			if(positionNodeControl != null)
			{
				positionNodeControl.setClient(client);
				cycleControl.setClient(client);
			}
		}
		
		override protected function setup():void
		{
			path = box.getModel() as Path;	
		} 
		
		override protected function createControls():void
		{
			nodeListOffset = 44;
			
			trace("Create Position Control : " + path.getCurrentPosition());
			positionNodeControl = createControl(path.getCurrentPosition(),0) as OscNodeControl;
			positionNodeControl.setAddress("/box/pos");
			addChild(positionNodeControl);
			
			cycleControl = new OscCycleControl((box as PathBox).getGoPath(),0);
			cycleControl.y = 22;
			cycleControl.setAddress("/cycle");
			addChild(cycleControl);
			super.createControls();
		}
	}
}