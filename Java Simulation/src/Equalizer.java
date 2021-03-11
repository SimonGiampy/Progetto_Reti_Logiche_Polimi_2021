import java.io.*;

public class Equalizer {
	
	public static void main(String[] args) {
		String filePath = "D:\\University\\3 Year\\2 Semester\\Progetto Reti\\Simulation\\src\\";
		String fileInput = "input_4x3.txt";
		String fileOutput = "output_4x3.txt";
		int width, height;
		
		try {
			BufferedReader reader = new BufferedReader(new FileReader(filePath + fileInput));
			width = Integer.parseInt(reader.readLine());
			height = Integer.parseInt(reader.readLine());
			int[] image = new int[height * width];
			for (int i = 0; i < width * height; i++) {
				image[i] = Integer.parseInt(reader.readLine());
			}
			
			if (reader.readLine().equals(".")) {
				System.out.println("read complete");
			}
			reader.close();
			
			int[] equalized = equalize(image, width, height);
			
			BufferedWriter writer = new BufferedWriter(new FileWriter(filePath + fileOutput));
			
			for (int i = 0; i < width * height; i++) {
				writer.write(equalized[i] + "\n");
			}
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	private static int[] equalize(int[] image, int width, int height) {
		int delta_value = maxValue(image) - minValue(image);
		int shift_level = (int) (8.0 - Math.floor(Math.log10(delta_value + 1) / Math.log10(2)));
		
		int temp_pixel;
		int[] result = new int[width * height];
		for (int i = 0; i < width * height; i++) {
			temp_pixel = (int) ((image[i] - minValue(image)) * Math.pow(2, shift_level));
			result[i] = Math.min(255, temp_pixel);
		}
		return result;
	}
	
	private static int maxValue(int[] vector) {
		int max = 0;
		for (int x: vector) {
			if (x > max) max = x;
		}
		return max;
	}
	
	private static int minValue(int[] vector) {
		int min = 255;
		for (int x: vector) {
			if (x < min) min = x;
		}
		return min;
	}
}
