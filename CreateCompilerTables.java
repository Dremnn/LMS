import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class CreateCompilerTables {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?sslmode=require&prepareThreshold=0";
        String user = "postgres.lsebmiopczckcquzytja";
        String pass = "sP6dQPEXO5g8g2xG";
        
        String sqlCodingExercises = "CREATE TABLE IF NOT EXISTS coding_exercises (id SERIAL PRIMARY KEY, lesson_id INT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE, description TEXT, language VARCHAR(50) NOT NULL, initial_code TEXT);";
        String sqlExerciseTestCases = "CREATE TABLE IF NOT EXISTS exercise_test_cases (id SERIAL PRIMARY KEY, exercise_id INT NOT NULL REFERENCES coding_exercises(id) ON DELETE CASCADE, input_data TEXT, expected_output TEXT NOT NULL, is_hidden BOOLEAN NOT NULL DEFAULT FALSE, points INT DEFAULT 10);";
        String sqlStudentSubmissions = "CREATE TABLE IF NOT EXISTS student_code_submissions (id SERIAL PRIMARY KEY, student_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE, exercise_id INT NOT NULL REFERENCES coding_exercises(id) ON DELETE CASCADE, submitted_code TEXT NOT NULL, status VARCHAR(50) NOT NULL, output_message TEXT, submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement()) {
            System.out.println("Executing SQL...");
            stmt.executeUpdate(sqlCodingExercises);
            stmt.executeUpdate(sqlExerciseTestCases);
            stmt.executeUpdate(sqlStudentSubmissions);
            System.out.println("Tables created successfully!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
