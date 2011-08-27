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

import java.io.IOException;

import com.cycling74.max.MaxObject;
import com.relivethefuture.osc.transport.OscServer;

public class OSCHTTP extends MaxObject
{

	private OscServer		server;
	private MaxOscListener	listener;

	public OSCHTTP()
	{
		// declareOutlets(new int[] { DataTypes.ALL });
		createInfoOutlet(false);
		declareTypedIO("A", "M");
	}

	@Override
	protected void notifyDeleted()
	{
		server.stop();
	}

	public void addServer(int port)
	{
		post("Starting on " + port);

		server = new OscServer(port);
		server.setUDP(false);
		server.setOscFactory(new MaxMessageFactory(this));
		listener = new MaxOscListener(this);
		server.addOscListener(listener);
		try
		{
			server.start();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
}
