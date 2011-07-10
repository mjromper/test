package es.tid.tabs;

import android.content.Intent;
import android.os.Bundle;
import es.tid.tabs.records.BDResultsActivity;

public class RecordsGroupActivity extends TabGroupActivity {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		startChildActivity("BDResultsActivity", new Intent(this, BDResultsActivity.class));
	}
}
