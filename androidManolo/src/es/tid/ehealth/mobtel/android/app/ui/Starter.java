package es.tid.ehealth.mobtel.android.app.ui;

import android.os.Bundle;

import com.google.code.microlog4android.Level;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;
import com.google.code.microlog4android.appender.FileAppender;
import com.google.code.microlog4android.config.PropertyConfigurator;
import com.google.code.microlog4android.format.PatternFormatter;

import es.tid.ehealth.mobtel.android.app.listeners.PowerSignal;
import es.tid.ehealth.mobtel.android.common.components.AppActivity;

public class Starter extends AppActivity {
	
	private static final Logger logger = LoggerFactory.getLogger(Starter.class);
	
	public static final int ENTRY_POINT=0;
	public static final int CONTACTINFO=1;
	public static final int CALL_PROMPT = 2;
	public static final int CALLINGCONTACT = 3;
	public static final int CALLESTABLISHED = 4;
	public static final int EMERGENCY = 5;
	
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
		micrologMainConfigurator();		
		logger.info("START TELECARE APPLICATION!!!!");	
		new PowerSignal(getApplicationContext());
		EntryPoint.launch(this);
	}
	
	public void micrologMainConfigurator() {

		PropertyConfigurator.getConfigurator(this).configure();
		int numApp = LoggerFactory.getLogger().getNumberOfAppenders();
		
		PatternFormatter formatter = new PatternFormatter();
		//formatter.setPattern("[%d] [%t] [%P] %c - %m %T");
		formatter.setPattern("[%d]%:[%P] [%c] - %m %T");		
		
		for (int i=0;i<numApp;i++){
			//if (LoggerFactory.getLogger().getAppender(i).toString().contains("FileAppender")){
				//LoggerFactory.getLogger().removeAppender(LoggerFactory.getLogger().getAppender(i));
			//}else{
				LoggerFactory.getLogger().getAppender(i).setFormatter(formatter);		
			//}				 
		}
		FileAppender myFileAppender = new FileAppender();
		myFileAppender.setFileName("telecare_log.txt");
		myFileAppender.setFormatter(formatter);
		LoggerFactory.getLogger().addAppender(myFileAppender);
		LoggerFactory.getLogger().setLevel(Level.DEBUG);

	}

}