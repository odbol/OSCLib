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
package com.relivethefuture.osc;

import java.util.ArrayList;
import java.util.Iterator;

import com.cycling74.max.MaxObject;
import com.relivethefuture.osc.data.OscListener;
import com.relivethefuture.osc.data.OscBundle;
import com.relivethefuture.osc.data.OscMessage;
import com.relivethefuture.osc.data.OscPacket;

public class MaxOscListener implements OscListener
{
	private MaxObject maxObject;

	public MaxOscListener(MaxObject max)
	{
		maxObject = max;
		MaxObject.post("Creating Listener");
	}

	public void handleBundle(OscBundle bundle)
	{
		//MaxObject.post("HandleBundle " + bundle.packets.size());
		ArrayList<OscPacket> packets = bundle.getPackets();
		for (Iterator<OscPacket> i = packets.iterator(); i.hasNext();)
		{
			OscPacket oscPacket = (OscPacket) i.next();
			if(oscPacket.isBundle())
			{
				handleBundle((OscBundle) oscPacket);
			}
			else
			{
				handleMessage((OscMessage) oscPacket);
			}
		}
	}

	public void handleMessage(OscMessage msg)
	{
		//MaxObject.post("HandleMessage " + msg.getAddress());
		if(msg instanceof MaxOscMessage)
		{
			MaxOscMessage maxMsg = (MaxOscMessage) msg;
			maxObject.outlet(0, maxMsg.getAddress(),maxMsg.getAtoms());
		}
		else
		{
			// convert normal message arguments into atoms.
			MaxObject.post("Message isnt a Max OSC Message " + msg.getAddress());
		}
	}

}
