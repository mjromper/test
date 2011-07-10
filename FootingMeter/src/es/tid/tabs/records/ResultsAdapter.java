package es.tid.tabs.records;

import java.util.ArrayList;
import java.util.Date;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import es.tid.R;
import es.tid.database.bo.Race;

public class ResultsAdapter extends BaseAdapter
{
	private BDResultsActivity activity;
	private ArrayList<Race> resultsList;

	public ResultsAdapter(BDResultsActivity activity, ArrayList<Race> racesList)
	{
		this.activity = activity;
		this.resultsList = racesList;
	}

	public int getCount()
	{
		return resultsList.size();
	}

	public Race getItem(int position)
	{
		return resultsList.get(position);
	}

	public long getItemId(int position)
	{
		return position;
	}

	public View getView(final int position, View convertView, ViewGroup viewGroup)
	{
		final Race entry = resultsList.get(position);
		if (convertView == null)
		{
			LayoutInflater inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			convertView = inflater.inflate(R.layout.bd_results_row, null);
		}
		
		TextView resultsName = (TextView) convertView.findViewById(R.id.resultsName);
		resultsName.setText(entry.getName());

		TextView resultsDate= (TextView) convertView.findViewById(R.id.resultsDate);
		resultsDate.setText(new Date(entry.getDate()).toString());

		
		return convertView;
	}
}
