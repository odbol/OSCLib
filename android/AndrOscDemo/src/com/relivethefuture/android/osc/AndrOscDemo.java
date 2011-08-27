package com.relivethefuture.android.osc;

import java.io.IOException;
import java.net.InetSocketAddress;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

import com.relivethefuture.osc.data.BasicOscListener;
import com.relivethefuture.osc.data.OscMessage;
import com.relivethefuture.osc.transport.OscClient;
import com.relivethefuture.osc.transport.OscServer;

public class AndrOscDemo extends Activity implements OnClickListener {
	private static final String TAG = "AndrOscDemo";
	private OscClient sender;
	private Button playButton;
	private Button stopButton;
	
	private OscServer server;

	public class LooperListener extends BasicOscListener {
		public Context c;
		
		@Override
		public void handleMessage(OscMessage msg) {
			System.out.println("Message " + msg.getAddress());
			System.out.println("Type Tags " + msg.getTypeTags());
			
			Toast.makeText(AndrOscDemo.this, "OSCmessage: " + msg.toString(), Toast.LENGTH_LONG);
			
		}
	}

	
	
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		sender = new OscClient(true);
		String destination = "10.0.2.2";
		int destPort = 10000;
		InetSocketAddress addr = new InetSocketAddress(destination, destPort);
		sender.connect(addr);

		playButton = (Button) this.findViewById(R.id.play);
		playButton.setOnClickListener(this);
		stopButton = (Button) this.findViewById(R.id.stop);
		stopButton.setOnClickListener(this);
		
		try {
			server = new OscServer(7999);
			server.start();
		}
		catch (IOException e) {
			Toast.makeText(this, "Failed to start OSC server: " + e.getMessage(), Toast.LENGTH_LONG);
		}
		server.addOscListener(new LooperListener());
		
	}

	@Override
	public void onClick(View v) {
		OscMessage msg = null;

		if (v == playButton) {
			msg = new OscMessage("/play");

		} else if (v == stopButton) {
			msg = new OscMessage("/stop");
		}

		if (msg != null) {
			try {
				sender.sendPacket(msg);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}