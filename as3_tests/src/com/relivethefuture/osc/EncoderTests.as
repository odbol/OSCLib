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

package com.relivethefuture.osc
{
	import com.relivethefuture.osc.core.OscEncoder;
	import com.relivethefuture.osc.core.OscMessage;
	
	import flash.utils.ByteArray;
	
	import net.digitalprimates.fluint.tests.TestCase;

	public class EncoderTests extends TestCase
	{
		private var encoder:OscEncoder;
		private var outputBuffer:ByteArray;
		
		override protected function setUp():void
		{
			encoder = new OscEncoder();
			outputBuffer = new ByteArray();	
		}
		
		[Test]
		public function checkSomethingIsPutInBuffer():void
		{
			var msg:OscMessage = new OscMessage("/test");
			encoder.encode(msg,outputBuffer);
			assertTrue(outputBuffer.length > 0);
		}
	}
}