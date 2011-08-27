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
	import com.hydrotik.go.HydroTween;
	import com.relivethefuture.components.BasicNodeBox;
	import com.relivethefuture.components.NodeBox;
	import com.relivethefuture.events.NodeBoxEvent;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import mx.effects.easing.Quadratic;
	import mx.effects.easing.Quintic;

	public class WorkArea extends Sprite
	{
		private var boxes:Array;
		
		private var columns:uint = 4;
		private var paddingX:uint = 4;
		private var paddingY:uint = 24;
		private var columnWidth:uint;
		private var rowHeight:uint;
		
		private var area:Rectangle;
		private var itemSize:Rectangle;
		
		private var focusedBox:NodeBox;
		
		private var boxBeingClosed:BasicNodeBox;
		private var boxBeingClosedRowIndex:uint;
		
		private var removalQueue:Array;
		
		private var nextColumn:int = 0;
		private var nextRow:int = 0;
		
		public function WorkArea()
		{
			super();
			boxes = [];
			area = new Rectangle(0,0,624,620);
			itemSize = new Rectangle(0,0,100,100);
			
			columns = Math.floor(area.width / (itemSize.width + paddingX));
			
			columnWidth = itemSize.width + paddingX;
			rowHeight = itemSize.height + paddingY;
			
			removalQueue = [];
		}
		
		public function getFocusedBox():NodeBox
		{
			return focusedBox;
		}
		
		public function createBox(c:Class):BasicNodeBox
		{
			var b:BasicNodeBox = new c(itemSize);

			trace("Create box : " + b);
			b.addEventListener(NodeBoxEvent.ZOOM,zoomBox);
			b.addEventListener(NodeBoxEvent.CLOSE,closeBox);
			addBox(b);
			
			return b;
		}
		
		public function addBox(b:BasicNodeBox):void
		{
			b.scaleX = 0.01;
			b.scaleY = 0.01;
			b.alpha = 0;
			
			var destX:Number = nextColumn * columnWidth;
			var destY:Number = nextRow * rowHeight;
			
			b.x = destX + (columnWidth / 2);
			b.y = destY + (rowHeight / 2);
			boxes.push(b);
			
			nextColumn = boxes.length % columns;
			nextRow = Math.floor(boxes.length / columns);
			
			trace("NEXT : " + nextColumn + ", " + nextRow);
			
			addChild(b);
			
			HydroTween.go(b, {scaleX:1,scaleY:1,x:destX,y:destY,alpha:1}, 0.7, 0, Quintic.easeOut, null, null, null,null);
		}
		
		private function zoomBox(event:NodeBoxEvent):void
		{
			if(focusedBox == null)
			{
				zoomTo(event.nodeBox);
			}
			else
			{
				showAll();
			}
		}
		
		private function closeBox(event:NodeBoxEvent):void
		{
			trace("CLOSE BOX : " + event.nodeBox + " : " + boxBeingClosed + " : " + removalQueue.length);
			
			if(boxBeingClosed != null)
			{
				removalQueue.push(event.nodeBox);
			}
			else
			{
				removeBox(event.nodeBox as BasicNodeBox);
			}
		}
		
		private function removeBox(b:BasicNodeBox):void
		{
			trace("Remove Box : " + b);
			boxBeingClosed = b;
			var destX:Number = b.x + (columnWidth / 2);
			var destY:Number = b.y + (rowHeight / 2);
			boxBeingClosedRowIndex = Math.floor(b.y / rowHeight);
	
			HydroTween.go(b, {scaleX:0,scaleY:0,x:destX,y:destY,alpha:0}, 0.3, 0, Quintic.easeOut, deleteBox, null, null,null);
		}
		
		private function deleteBox():void
		{
			trace("DELETE BOX " + boxBeingClosed + " : " + boxBeingClosedRowIndex + " : " + boxes.length);
			boxBeingClosed.stop();
			
			removeChild(boxBeingClosed);
			
			var i:uint = 0;
			var box:BasicNodeBox;

			var boxColumn:uint = 0;

			// 2. Get box row and column (BR, BC) and remove
			for(i = 0;i<boxes.length;i++)
			{
				box = boxes[i];
				if(box == boxBeingClosed)
				{
					boxColumn = i % columns;
					boxBeingClosedRowIndex = Math.floor(i / columns);
					break;
				}
			}
			
			var destX:uint;
			var destY:uint;
			var index:uint;
			
			var lastColumn:uint = (boxes.length - 1) % columns;
			var lastRow:uint = Math.floor((boxes.length - 1) / columns);
			
			trace("COLUMNS : " + boxColumn + " : " + nextColumn);
			
			// 3. if removed box is to the left of column, move left the boxes which are to the right
			//    if removed box is to the right of column, move right the boxes which are to the left
			if(boxColumn < lastColumn)
			{
				slideLeft(boxColumn+1,lastColumn);
				trace("SLIDE LEFT " + boxColumn + " : " + nextColumn);
			}
			else if(boxColumn > lastColumn)
			{
				trace("SLIDE RIGHT " + boxColumn + " : " + nextColumn);
				slideRight(lastColumn,boxColumn-1);
			}
			else if(boxBeingClosedRowIndex < lastRow)
			{
				// 4. move up column (C)
				slideUpColumn();	
			}
			else
			{
				removeComplete();
			}
		}

		private function slideLeft(start:uint,end:uint):void
		{
			var index:uint = 0;
			var box:BasicNodeBox;
			var destX:uint;
			
			var callback:Function = null;
			
			for(var i:uint = start;i<=end;i++)
			{
				index = i + (boxBeingClosedRowIndex * columns);
				trace("SLIDE LEFT INDEX : " + index);
				box = boxes[index];
				// slide one place left
				destX = (i - 1) * columnWidth;
				if(i == end)
				{
					callback = slideComplete;		
				}
				HydroTween.go(box, {x:destX}, 0.2, 0, Quintic.easeOut, callback, null, null,null);
				// A box going left means remove one from its index
				boxes[index-1] = boxes[index];				
			}	
		}
		
		private function slideRight(start:uint,end:uint):void
		{
			var index:uint = 0;
			var box:BasicNodeBox;
			var destX:uint;
			
			var callback:Function = null;
			
			for(var i:int = end;i>=start;i--)
			{
				index = i + (boxBeingClosedRowIndex * columns);
				box = boxes[index];
				trace("SLIDE RIGHT INDEX : " + index + " : " + box);
				// slide one place right
				destX = (i + 1) * columnWidth;

				if(i == start)
				{
					callback = slideComplete;		
				}
				
				HydroTween.go(box, {x:destX}, 0.2, 0, Quintic.easeOut, callback, null, null,null);
				// a box going right means add one to its index
				boxes[index+1] = boxes[index];
			}			
		}
		
		private function slideComplete():void
		{
			trace("Slide Complete " + nextColumn + " : " + columns + " : " + boxBeingClosedRowIndex);
			if(boxBeingClosedRowIndex < (Math.floor((boxes.length - 1) / columns)))
			{
				slideUpColumn();
			}
			else
			{
				removeComplete();
			}
		}
		
		private function slideUpColumn():void
		{
			var lastRow:uint = Math.floor((boxes.length - 1) / columns);
			trace("Slide up column : " + lastRow + ", " + boxBeingClosedRowIndex);
			
			var destY:uint;
			var box:BasicNodeBox;
			
			var callback:Function = null;
			
			if(nextColumn == 0)
			{
				nextColumn = 6;
			}
			for(var i:uint = boxBeingClosedRowIndex + 1;i<=lastRow;i++)
			{
				var bi:uint = (nextColumn - 1) + (i * columns);
				trace("BI : " + bi); 
				box = boxes[bi];
				destY = box.y - rowHeight;
				if(i == lastRow)
				{
					callback = removeComplete;
				}
				HydroTween.go(box, {y:destY}, 0.2, 0, Quintic.easeOut, callback, null, null,null);
				// A box going up means we subtract 'columns' from its index;
				trace("Move up : " + bi + " to " + (bi - columns));
				boxes[bi - columns] = boxes[bi];
			}
		}
		
		private function removeComplete():void
		{
			boxBeingClosed = null;
			// Remove the last one as its not needed.
			boxes.pop();
			trace("Remove Complete " + boxes.length);
			nextColumn = boxes.length % columns;
			nextRow = Math.floor(boxes.length / columns);
			trace("NEXT : " + nextColumn + ", " + nextRow);
			
			for(var i:uint = 0;i<boxes.length;i++)
			{
				var b:BasicNodeBox = boxes[i];
				
				var c:int = i % columns;
				var r:int = Math.floor(i / columns);
				
				var bc:int = b.x / columnWidth;
				var br:int = b.y / rowHeight;
				
				trace("BOX " + i + " : " + c + ", " + r + " : " + bc + ", " + br);
				if(bc != c || br != r)
				{
					trace("Box is in wrong place");
				}
			}
			if(removalQueue.length > 0)
			{
				removeBox(boxes.shift());
			}
		}
		
		public function zoomTo(b:NodeBox):void
		{
			HydroTween.go(b, {scaleX:5.5,scaleY:5.5,x:0,y:0}, 1, 0, Quadratic.easeOut, null, null, null,null);
			
			focusedBox = b;
			for(var i:uint = 0;i<boxes.length;i++)
			{
				var box:NodeBox = boxes[i];
				
				if(box != b)
				{
					HydroTween.go(box, {alpha:0}, 1, 0, Quintic.easeOut, null, null, null,null);
				}
			}
		}
		
		public function showAll():void
		{
			for(var i:uint = 0;i<boxes.length;i++)
			{
				var box:NodeBox = boxes[i];
				
				if(box != focusedBox)
				{
					HydroTween.go(box, {alpha:1}, 1, 0, Quadratic.easeIn, null, null, null,null);
				}
				else
				{
					var destX:Number = (i % columns) * (itemSize.width + paddingX);
					var destY:Number = Math.floor(i / columns) * (itemSize.height + paddingY);
					HydroTween.go(box, {scaleX:1,scaleY:1,x:destX,y:destY}, 1, 0, Quadratic.easeOut, null, null, null,null);
				}
			}
			
			focusedBox = null;
		}
		
		private function draw():void
		{
			graphics.lineStyle(0,0x000000);
			graphics.moveTo(0,0);
			graphics.lineTo(area.width,0);
			graphics.lineTo(area.width,area.height);
			graphics.lineTo(0,area.height);
			graphics.lineTo(0,0);
		}
	}
}