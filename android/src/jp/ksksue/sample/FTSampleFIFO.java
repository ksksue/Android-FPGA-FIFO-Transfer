package jp.ksksue.sample;
/*
 * Copyright (C) 2012 @ksksue
 * Licensed under the Apache License, Version 2.0
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import jp.ksksue.serial.R;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbManager;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import jp.ksksue.driver.serial.*;
public class FTSampleFIFO extends Activity {
	
	final int SERIAL_BAUDRATE = FTDriver.BAUD115200;
	final int mOutputType = 0;
	
	final boolean SHOW_LOGCAT = true;
	
	FTDriver mSerial;

	private TextView mTvSerial;
	private String mText;
	private boolean mStop=false;
	private boolean mStopped=true;
		
	String TAG = "FTSampleTerminal";
    
    Handler mHandler = new Handler();

    private Button btWrite;
    private EditText etWrite;
    
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        mTvSerial = (TextView) findViewById(R.id.tvSerial);
        btWrite = (Button) findViewById(R.id.btWrite);
        etWrite = (EditText) findViewById(R.id.etWrite);
        
		if(SHOW_LOGCAT) { Log.d(TAG,"New FTDriver"); }
        // get service
        mSerial = new FTDriver((UsbManager)getSystemService(Context.USB_SERVICE));
          
        // listen for new devices
        IntentFilter filter = new IntentFilter();
        filter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
        filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
        registerReceiver(mUsbReceiver, filter);
        
		if(SHOW_LOGCAT) { Log.d(TAG,"Begin Serial"); }
        if(mSerial.begin(SERIAL_BAUDRATE)) {
        	mainloop();
        }
        else if(SHOW_LOGCAT) { Log.d(TAG,"Cannot Open Serial"); }
        
        // ---------------------------------------------------------------------------------------
       // Write Button
        // ---------------------------------------------------------------------------------------
        btWrite.setOnClickListener(new View.OnClickListener() {
    		@Override
    		public void onClick(View v) {
    			String strWrite = etWrite.getText().toString();
    			mSerial.write(strWrite.getBytes(),strWrite.length());
    		}
        });
    }
    
    @Override
    public void onDestroy() {
		mSerial.end();
		mStop=true;
       unregisterReceiver(mUsbReceiver);
		super.onDestroy();
    }
    
	private void mainloop() {
		new Thread(mLoop).start();
	}
	
	private Runnable mLoop = new Runnable() {
		@Override
		public void run() {
			int i;
			int len;
			int verifyData=0;
			int verifyLoop=0;
			byte[] rbuf = new byte[4096];
			byte[] wbuf = new byte[0xFF];
			boolean failFlag = false;
			long start,stop;
			
			//////////////////////////////////////////////////////////
			// Write 0x00 to 0xFF
			//////////////////////////////////////////////////////////
			if(SHOW_LOGCAT) { Log.d(TAG,"Start Write Loop"); }
			for(i=0;i<0xFF;++i) {
				wbuf[i]=(byte)i;
			}
			mSerial.write(wbuf,0xFF);

			if(SHOW_LOGCAT) { Log.d(TAG,"Start Read Loop"); }

			double totalTime = 0.0;
			start = System.nanoTime();
			for(;;){//this is the main loop for transferring
				//////////////////////////////////////////////////////////
				// Read and Display to Terminal
				//////////////////////////////////////////////////////////
				len = mSerial.read(rbuf);

				// TODO: UI:Show last line
				if(len > 0) {
					if(SHOW_LOGCAT) { Log.d(TAG,"Read  Length : "+len); }
					for(i=0;i<len;++i) {
//						if(SHOW_LOGCAT) { Log.d(TAG,"Read   Data : "+rbuf[i]); }
//						if(SHOW_LOGCAT) { Log.d(TAG,"Verify Data : "+verifyData); }
						if(((int)rbuf[i] & 0xFF) != (verifyData & 0xFF)) {
							if(SHOW_LOGCAT) { Log.d(TAG,"Error Read Data : "+((int)rbuf[i] & 0xFF) ); }
//							if(SHOW_LOGCAT) { Log.d(TAG,"Verify Data : "+(verifyData & 0xFF)); }
							failFlag = true;
						} 
						if(((int)rbuf[i] & 0xFF) == 0xFF) {
							stop = System.nanoTime();
							
							totalTime += (stop - start) / 1000.0; // us
							verifyData = 0x01;
							++verifyLoop;
							if(SHOW_LOGCAT) { Log.d(TAG,"Verify Loop : "+verifyLoop); }
							if(SHOW_LOGCAT) { Log.d(TAG,"One Loop    : "+((stop - start)/1000.0) + " us"); }
							if(SHOW_LOGCAT) { Log.d(TAG,"Average     : "+ (totalTime/(double)verifyLoop) + " us"); }
							if(failFlag) { Log.d(TAG,"Verify failed."); }
							failFlag = false;
							
							start = System.nanoTime();
						} else {
							++verifyData;
						}
					}
				}
				
				if(mStop) {
					mStopped = true;
					return;
				}
			}
		}
	};
	
	
    // BroadcastReceiver when insert/remove the device USB plug into/from a USB port  
    BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
    		String action = intent.getAction();
    		if (UsbManager.ACTION_USB_DEVICE_ATTACHED.equals(action)) {
    			mSerial.usbAttached(intent);
				mSerial.begin(SERIAL_BAUDRATE);
    			mainloop();
				
    		} else if (UsbManager.ACTION_USB_DEVICE_DETACHED.equals(action)) {
    			mSerial.usbDetached(intent);
    			mSerial.end();
    			mStop=true;
    		}
        }
    };
}
