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
package com.relivethefuture.supercollider.control
{
	/**
	 * Action constants used when creating Synths or Groups
	 */
	public class AddActions
	{
		// 0 - add the new group to the the head of the group specified by the add target ID.
		public static const HEAD:uint = 0;
		// 1 - add the new group to the the tail of the group specified by the add target ID.
		public static const TAIL:uint = 1;
		// 2 - add the new group just before the node specified by the add target ID.
		public static const BEFORE:uint = 2;
		// 3 - add the new group just after the node specified by the add target ID.
		public static const AFTER:uint = 3;
		// 4 - the new node replaces the node specified by the add target ID. The target node is freed.
		public static const REPLACE:uint = 4;
	}
}