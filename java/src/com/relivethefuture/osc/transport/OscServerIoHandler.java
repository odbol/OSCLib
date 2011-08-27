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
package com.relivethefuture.osc.transport;

import java.util.ArrayList;
import java.util.Iterator;

import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IoSession;

import com.relivethefuture.osc.data.OscBundle;
import com.relivethefuture.osc.data.OscListener;
import com.relivethefuture.osc.data.OscMessage;

public class OscServerIoHandler extends IoHandlerAdapter {
	public static final String INDEX_KEY = OscServerIoHandler.class.getName()
			+ ".INDEX";
	private ArrayList<OscListener> listeners;

	public void addListener(OscListener listener) {
		if (listeners == null) {
			listeners = new ArrayList<OscListener>();
		}
		listeners.add(listener);
	}

	public void removeListener(OscListener listener) {
		listeners.remove(listener);
	}

	public void sessionOpened(IoSession session) throws Exception {
		session.setAttribute(INDEX_KEY, new Integer(0));
		if (listeners == null) {
			listeners = new ArrayList<OscListener>();
		}
	}

	public void exceptionCaught(IoSession session, Throwable cause)
			throws Exception {
		// SessionLog.warn(session, cause.getMessage(), cause);
	}

	public void messageReceived(IoSession session, Object message)
			throws Exception {
		if (message instanceof OscMessage) {
			OscMessage oscMessage = (OscMessage) message;
			for (Iterator<OscListener> i = listeners.iterator(); i.hasNext();) {
				OscListener listener = (OscListener) i.next();
				listener.handleMessage(oscMessage);
			}

			// SessionLog.debug(session, "Received OSC Message : " +
			// oscMessage.getAddress() + " : " +
			// oscMessage.getArguments().size());
		} else if (message instanceof OscBundle) {
			OscBundle oscBundle = (OscBundle) message;
			for (Iterator<OscListener> i = listeners.iterator(); i.hasNext();) {
				OscListener listener = (OscListener) i.next();
				listener.handleBundle(oscBundle);
			}

			// SessionLog.debug(session, "Received OSC Message : " +
			// oscBundle.getTimestamp() + " : " +
			// oscBundle.getPackets().size());
		}
		// NOTE : uncomment this to echo packets back to the client. useful for
		// testing.
		// session.write(message);
	}

}
