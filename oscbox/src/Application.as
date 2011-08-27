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
	import com.relivethefuture.components.BasicNodeBox;
	import com.relivethefuture.components.BoxInspector;
	import com.relivethefuture.components.IKBox;
	import com.relivethefuture.components.OrbitBox;
	import com.relivethefuture.components.PathBox;
	import com.relivethefuture.events.NodeBoxEvent;
	import com.relivethefuture.osc.core.OscClient;
	import com.relivethefuture.oscbox.OscNodeManager;
	import com.relivethefuture.oscbox.PathBoxNodeManager;
	import com.relivethefuture.oscbox.SocketFlowController;
	import com.relivethefuture.oscbox.Toolbar;
	import com.relivethefuture.oscbox.WorkArea;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import org.goasap.GoEngine;
	
	public class Application extends Sprite
	{
		private var toolbar:Toolbar;
		
		private var workArea:WorkArea;
		private var inspector:BoxInspector;
		
		private var boxes:Array;
		
		private var nodeManager:OscNodeManager;
		
		private var client:OscClient;
		private var flowControl:SocketFlowController;
		
		public function Application()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP;

			workArea = new WorkArea();
			workArea.addEventListener(NodeBoxEvent.ZOOM,boxZoomed);
			
			inspector = new BoxInspector();
			
			toolbar = new Toolbar();
			
			addChild(workArea);
			addChild(inspector);
			addChild(toolbar);
			
			workArea.y = 45;
			inspector.x = 630;
			inspector.y = 45;
			
			toolbar.addItem("Path",addNewPath);
			toolbar.addItem("IK",addNewIK);
			toolbar.addItem("Orbit",addNewOrbiter);
			
			boxes = [];
			
			client = new OscClient("localhost",4444);
			flowControl = new SocketFlowController(client);
			GoEngine.addItem(flowControl);
		}
		
		private function boxZoomed(event:NodeBoxEvent):void
		{
			trace("BOX ZOOMED " + event.nodeBox);
			
			if(workArea.getFocusedBox() != null)
			{
				inspector.show(workArea.getFocusedBox());
			}
		}
		
		private function addNewPath(event:Event):void
		{
			var b:BasicNodeBox = workArea.createBox(PathBox);
			b.setNodeManager(new PathBoxNodeManager(b,client));
			addBox(b);
		}
		
		private function addNewIK(event:Event):void
		{
			var b:BasicNodeBox = workArea.createBox(IKBox);
			b.setNodeManager(new OscNodeManager(b,client));
			addBox(b);
		}
		
		private function addNewOrbiter(event:Event):void
		{
			var b:BasicNodeBox = workArea.createBox(OrbitBox);
			b.setNodeManager(new OscNodeManager(b,client));
			addBox(b);
		}
		
		private function addBox(b:BasicNodeBox):void
		{
			inspector.addItem(b);
			b.addEventListener(NodeBoxEvent.INSPECT,inspectBox);
			inspector.show(b);
		}
		
		private function inspectBox(event:NodeBoxEvent):void
		{
			trace("Inspect Box : " + event.nodeBox);
			inspector.show(event.nodeBox);
		}
	}
}