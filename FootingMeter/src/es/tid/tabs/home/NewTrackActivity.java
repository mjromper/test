package es.tid.tabs.home;


import java.util.Date;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import es.tid.R;
import es.tid.database.bo.Race;
import es.tid.database.impl.DbRacesAccess;

public class NewTrackActivity extends Activity {
	private EditText runningName;


	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.new_track_layout);

		// trackName = (Button) findViewById(R.id.newTrackTrackName);
		runningName = (EditText) findViewById(R.id.newTrackRunningName);
		
		final Button nextBtn = (Button) findViewById(R.id.start_btn);
		OnClickListener nextBtnListener = new OnClickListener() {
			@Override
			public void onClick(View v) {
				// elena
				// UtilsStride.trackName =
				// trackName.getSelectedItem().toString();
				UtilsStride.runningName = runningName.getText().toString();

				// ionut
				// sAux = "" + trackName.getText();
				// UtilsStride.currentFileName = sAux;
				// UtilsStride.newTrack = true;
//				TabGroupActivity parentActivity = (TabGroupActivity) getParent();
//				Intent intent = new Intent(parentActivity,
//						ChooseExerciseActivity.class);
//				parentActivity.startChildActivity("ChooseExerciseActivity",
//						intent);
				
				DbRacesAccess dbRaces = new DbRacesAccess(NewTrackActivity.this, DbRacesAccess.DB_NAME);
				Race race = new Race();
				race.setName(runningName.getText().toString());
				race.setDate(new Date().getTime());
				dbRaces.insert(race);

			}
		};

		nextBtn.setOnClickListener(nextBtnListener);
	}
}
