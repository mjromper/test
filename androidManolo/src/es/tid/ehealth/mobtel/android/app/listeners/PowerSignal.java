package es.tid.ehealth.mobtel.android.app.listeners;

import android.content.Context;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;
import es.tid.ehealth.mobtel.android.app.ui.EntryPoint;

public class PowerSignal
{
	//private static final Logger logger = LoggerFactory.getLogger(PowerSignal.class);
	/*
	 * This variables need to be global, so we can used them onResume and
	 * onPause method to stop the listener
	 */
	TelephonyManager Tel;
	MyPhoneStateListener MyListener;
	private int lastSignal = 0;
	
	@SuppressWarnings("static-access")
	public PowerSignal(Context c)
	{		
		// Update the listener, and start it 
		MyListener = new MyPhoneStateListener();
		Tel = (TelephonyManager)c.getSystemService(c.TELEPHONY_SERVICE);
		Tel.listen(MyListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);		
	}
	
	/* ���������� */
    /* Start the PhoneState listener */
    /* ���������� */
    private class MyPhoneStateListener extends PhoneStateListener
    {
      /* Get the Signal strength from the provider, each tiome there is an update */
      @Override
      public void onSignalStrengthsChanged(SignalStrength signalStrength)
      {
         super.onSignalStrengthsChanged(signalStrength);
         
         if(lastSignal != signalStrength.getGsmSignalStrength())
         {
        	 lastSignal = signalStrength.getGsmSignalStrength();
        	 //logger.debug("Signal strength: "+lastSignal);
        	 EntryPoint.setSignalImage(lastSignal);
         }
      }

    };/* End of private Class */

}/* GetGsmSignalStrength */