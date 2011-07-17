/***
 Copyright (c) 2009 
 Author: Stefan Klumpp <stefan.klumpp@gmail.com>
 Web: http://stefanklumpp.com

 Licensed under the Apache License, Version 2.0 (the "License"); you may
 not use this file except in compliance with the License. You may obtain
 a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

package es.tid.ehealth.mobtel.android.common.json;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.zip.GZIPInputStream;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreProtocolPNames;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class JsonHttpClient {
	
	 private static final Logger logger = LoggerFactory.getLogger(JsonHttpClient.class);

	/**
	 * Method to send a Http request to a server in URL
	 * @param URL
	 * @param jsonObjSend
	 * @return JSONObject
	 */
	public static JSONObject SendHttpPost(String URL, JSONObject jsonObjSend) {

		try {
			DefaultHttpClient httpclient = new DefaultHttpClient();
			HttpPost httpPostRequest = new HttpPost(URL);

			StringEntity se;
			if (jsonObjSend != null){
			    logger.debug("Post: "+jsonObjSend.toString());
			    se = new StringEntity(jsonObjSend.toString(),HTTP.UTF_8);
			    // Set HTTP parameters
			    httpPostRequest.setEntity(se);
			}
			httpPostRequest.setHeader("Accept", "application/json");
			httpPostRequest.setHeader("Content-type", "application/json");
			//httpPostRequest.setHeader("Accept-Encoding", "gzip"); // only set this parameter if you would like to use gzip compression
			httpPostRequest.getParams().setBooleanParameter(CoreProtocolPNames.USE_EXPECT_CONTINUE, false);
			long t = System.currentTimeMillis();
			logger.debug("HTTPResponse received in [" + (System.currentTimeMillis()-t) + "ms]");
			int retries = 1;
			HttpEntity entity = null;			

			while (entity == null && retries <= 3){
			    HttpResponse response = (HttpResponse) httpclient.execute(httpPostRequest);

			    int statusCode = response.getStatusLine().getStatusCode();
			    logger.debug("STATUS RESPONSE CODE: "+statusCode);
			    final String reason = response.getStatusLine().getReasonPhrase();
			    logger.debug("RESPONSE STATUS REASON: "+reason);

			    // Get hold of the response entity (-> the data):
			    entity = response.getEntity();

			    if (entity != null) {
			        if (statusCode == 200) {
			            logger.debug("RESPONSE OK");

			            // Read the content stream
			            InputStream instream = entity.getContent();
			            Header contentEncoding = response.getFirstHeader("Content-Encoding");
			            if (contentEncoding != null && contentEncoding.getValue().equalsIgnoreCase("gzip")) {
			                instream = new GZIPInputStream(instream);
			            }

			            // convert content stream to a String
			            String resultString = convertStreamToString(instream);
			            logger.debug("resultString:"+resultString);
			            instream.close();
			            //resultString = resultString.substring(1,resultString.length()-1); // remove wrapping "[" and "]"

			            // Transform the String into a JSONObject
			            JSONObject jsonObjRecv = new JSONObject(resultString);
			            // Raw DEBUG output of our received JSON object:
			            logger.debug("<jsonobject>\n"+jsonObjRecv.toString()+"\n</jsonobject>");

			            return jsonObjRecv;
			        }else{
			            logger.debug("RESPONSE NOK");
			        }
			    } else{
			        retries++;
			    }
			}

		}
		catch (JSONException e)
		{
			// More about HTTP exception handling in another tutorial.
			// For now we just print the stack trace.
			logger.error("Error parsing JSON: "+e);
			return null;
		}
		catch (Exception e1)
        {
            // More about HTTP exception handling in another tutorial.
            // For now we just print the stack trace.
            logger.error("Error conecting to server: "+URL);
            logger.error("Error: "+e1);
            return null;
        }
		return null;
	}


	/**
	 * Emthod to convert stream json to string
	 * @param InputStream is
	 * @return json in type string 
	 */
	private static String convertStreamToString(InputStream is) {
		/*
		 * To convert the InputStream to String we use the BufferedReader.readLine()
		 * method. We iterate until the BufferedReader return null which means
		 * there's no more data to read. Each line will appended to a StringBuilder
		 * and returned as String.
		 * 
		 * (c) public domain: http://senior.ceng.metu.edu.tr/2009/praeda/2009/01/11/a-simple-restful-client-at-android/
		 */
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		StringBuilder sb = new StringBuilder();

		String line = null;
		try {
			while ((line = reader.readLine()) != null) {
				sb.append(line + "\n");
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				is.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return sb.toString();
	}

}
