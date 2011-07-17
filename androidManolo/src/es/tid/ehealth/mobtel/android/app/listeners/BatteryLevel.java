package es.tid.ehealth.mobtel.android.app.listeners;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class BatteryLevel extends BroadcastReceiver
{
	private static final Logger logger = LoggerFactory.getLogger(BatteryLevel.class);

	public static int Battery0 = 0;
	public static int Battery1 = 1;
	public static int Battery2 = 2;
	public static int Battery3 = 3;
	public static int Battery4 = 4;
	public static int BatteryCharging0 = 5;
	public static int BatteryCharging1 = 6;
	public static int BatteryCharging2 = 7;
	public static int BatteryCharging3 = 8;
	public static int BatteryCharging4 = 9;
	
	private int batteryLevel = 0;
	private boolean _plugged = false;
	private int lastBatteryStatus = 0;
	
	
		@Override
		public void onReceive(Context context, Intent intent)
		{
			boolean isPresent = intent.getBooleanExtra("present", false);
			int plugged = intent.getIntExtra("plugged", -1);
			int scale = intent.getIntExtra("scale", -1);			
			int rawlevel = intent.getIntExtra("level", -1);			

			if (isPresent)
			{
				if (rawlevel >= 0 && scale > 0) 
				{
					batteryLevel = (rawlevel * 100) / scale;
					
					if(plugged > -1)
						_plugged = true;					
				}
			} 
			else 
			{
				batteryLevel = -1;
			}
			
			if(lastBatteryStatus != batteryStatus())
			{
				lastBatteryStatus = batteryStatus();
				logger.debug("Battery level = "+lastBatteryStatus);
				//TODO Pintar la imagen que devuelve batteryStatus
			}
		}
	

	private int batteryStatus()
	{
		if(batteryLevel >= 75 && _plugged)
		{
			return BatteryCharging4;
		}
		
		if(batteryLevel >= 50 && batteryLevel < 75 && _plugged)
		{
			return BatteryCharging3;
		}
		
		if(batteryLevel >= 25 && batteryLevel < 50 && _plugged)
		{
			return BatteryCharging2;
		}
		
		if(batteryLevel >= 10 && batteryLevel < 25 && _plugged)
		{
			return BatteryCharging1;
		}
		
		if(batteryLevel < 10 && _plugged)
		{
			return BatteryCharging0;
		}
		
		if(batteryLevel >= 75)
		{
			return Battery4;
		}
		
		if(batteryLevel >= 50 && batteryLevel < 75)
		{
			return Battery3;
		}
		
		if(batteryLevel >= 25 && batteryLevel < 50)
		{
			return Battery2;
		}
		
		if(batteryLevel >= 10 && batteryLevel < 25)
		{
			return Battery1;
		}
		
		if(batteryLevel < 10)
		{
			return Battery0;
		}
		else
		{		
			return Battery0;
		}
	}
}
