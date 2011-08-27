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
package com.relivethefuture.osc.data;

import java.util.Iterator;

/**
 * Just an example of handling incoming packets, log message info and iterate
 * over the packets in a bundle.
 * 
 * @author Martin
 * 
 */
public class BasicOscListener implements OscListener {
	public void handleBundle(OscBundle bundle) {
		for (Iterator<OscPacket> iterator = bundle.packets.iterator(); iterator
				.hasNext();) {
			OscPacket packet = (OscPacket) iterator.next();
			if (packet.isBundle()) {
				handleBundle((OscBundle) packet);
			} else {
				handleMessage((OscMessage) packet);
			}
		}
	}

	public void handleMessage(OscMessage msg) {
		System.out.println("Message " + msg.getAddress());
		System.out.println("Type Tags " + msg.getTypeTags());
	}
}
