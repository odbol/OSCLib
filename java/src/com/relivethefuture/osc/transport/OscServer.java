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

import java.io.IOException;
import java.net.InetSocketAddress;

import org.apache.mina.core.service.IoAcceptor;
import org.apache.mina.filter.codec.ProtocolCodecFilter;
import org.apache.mina.filter.logging.LoggingFilter;
import org.apache.mina.transport.socket.DatagramSessionConfig;
import org.apache.mina.transport.socket.nio.NioDatagramAcceptor;
import org.apache.mina.transport.socket.nio.NioSocketAcceptor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.relivethefuture.osc.data.BasicOscFactory;
import com.relivethefuture.osc.data.BasicOscListener;
import com.relivethefuture.osc.data.OscListener;
import com.relivethefuture.osc.data.OscPacketFactory;

/**
 * OSC Server
 * 
 * Defaults to UDP, call setUDP(false) to use HTTP
 * 
 * 
 * @author Martin Wood-Mitrvoski
 */
public class OscServer {
	final Logger logger = LoggerFactory.getLogger(OscServer.class);

	private static final int PORT = 10000;
	private IoAcceptor acceptor;
	private OscServerIoHandler handler;
	private int port;
	private OscPacketFactory oscPacketFactory;

	private boolean udp = true;

	public OscServer(int port) {
		this.port = port;
		this.handler = new OscServerIoHandler();
	}

	public void setUDP(boolean udp) {
		this.udp = udp;
	}

	public void setOscFactory(OscPacketFactory factory) {
		oscPacketFactory = factory;
	}

	public void addOscListener(OscListener listener) {
		handler.addListener(listener);
	}

	public void removeOscListener(OscListener listener) {
		handler.removeListener(listener);
	}

	public void start() throws IOException {
		if (oscPacketFactory == null) {
			oscPacketFactory = new BasicOscFactory();
		}

		acceptor = createAcceptor();
		acceptor.getFilterChain().addLast("logger", new LoggingFilter());
		acceptor.getFilterChain().addLast(
				"protocol",
				new ProtocolCodecFilter(new OscCodecFactory(oscPacketFactory,
						udp)));
		acceptor.setHandler(handler);
		acceptor.bind(new InetSocketAddress(port));
		logger.info("server is listening at port " + port);
	}

	private IoAcceptor createAcceptor() {
		if (udp) {
			NioDatagramAcceptor nda = new NioDatagramAcceptor();
			DatagramSessionConfig dcfg = nda.getSessionConfig();
			dcfg.setReuseAddress(true);
			return nda;
		} else {
			return new NioSocketAcceptor();
		}
	}

	public void stop() {
		acceptor.unbind();
	}

	public static void main(String[] args) throws IOException {
		OscServer server = new OscServer(PORT);
		server.start();
		server.addOscListener(new BasicOscListener());
	}

}
