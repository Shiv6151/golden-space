package com.socialmedia.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.Map;

public class CloudinaryUtil {
    private static Cloudinary cloudinary;

    static {
        // Use environment variables on Render, fallback to defaults for portability
        String cloudName = System.getenv("CLOUDINARY_CLOUD_NAME") != null ? 
                System.getenv("CLOUDINARY_CLOUD_NAME") : "dmcltqixh";
        String apiKey = System.getenv("CLOUDINARY_API_KEY") != null ? 
                System.getenv("CLOUDINARY_API_KEY") : "296687126415345";
        String apiSecret = System.getenv("CLOUDINARY_API_SECRET") != null ? 
                System.getenv("CLOUDINARY_API_SECRET") : "W-f7j9ukSNDcRxWdGW6QX0_ELhE";

        cloudinary = new Cloudinary(ObjectUtils.asMap(
            "cloud_name", cloudName,
            "api_key", apiKey,
            "api_secret", apiSecret,
            "secure", true
        ));
    }

    public static String upload(Part part) {
        if (cloudinary == null) {
            System.err.println("Cloudinary not configured. Check environment variables.");
            return null;
        }

        try {
            // Create a temporary file to hold the upload data
            File tempFile = File.createTempFile("upload_", "_" + part.getSubmittedFileName());
            try (InputStream input = part.getInputStream();
                 FileOutputStream output = new FileOutputStream(tempFile)) {
                byte[] buffer = new byte[8192];
                int read;
                while ((read = input.read(buffer)) != -1) {
                    output.write(buffer, 0, read);
                }
            }

            // Upload the file to Cloudinary
            @SuppressWarnings("unchecked")
            Map<String, Object> uploadResult = (Map<String, Object>) cloudinary.uploader().upload(tempFile, ObjectUtils.emptyMap());
            tempFile.delete(); // Delete temp file

            return (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static boolean isConfigured() {
        return cloudinary != null;
    }
}
