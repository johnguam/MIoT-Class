package com.jguamie.miottask1android;

import android.graphics.Color;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import com.github.danielnilsson9.colorpickerview.view.ColorPickerView;
import com.github.danielnilsson9.colorpickerview.view.ColorPickerView.OnColorChangedListener;

public class LaunchActivity extends AppCompatActivity {

    private ColorPickerView mColorPickerView;
    private TextView mColorTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_launch);

        mColorPickerView = (ColorPickerView)findViewById(R.id.color_picker_view);
        mColorTextView = (TextView)findViewById(R.id.color_text_view);

        mColorPickerView.setOnColorChangedListener(mColorChangedListener);
    }

    OnColorChangedListener mColorChangedListener = new OnColorChangedListener() {
        @Override
        public void onColorChanged(int newColor) {
            int rgbRed = Color.red(newColor);
            int rgbGreen = Color.green(newColor);
            int rgbBlue = Color.blue(newColor);

            mColorTextView.setText("Red: " + rgbRed + ", Green: " + rgbGreen + ", Blue: " + rgbBlue);
        }
    };
}
