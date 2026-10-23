import java.sql.Connection;
import java.sql.DriverManager;
import java.io.FileInputStream;
import java.util.Properties;

public class TestOracle {
    public static void main(String[] args) {
        System.out.println("--- Test de connexion Oracle ---");
        try {
            Properties prop = new Properties();
            prop.load(new FileInputStream("socobis-ejb/src/java/apj.properties"));
            String url = prop.getProperty("apj.connection.url");
            String user = prop.getProperty("apj.connection.user");
            String pass = prop.getProperty("apj.connection.password");

            System.out.println("URL: " + url);
            System.out.println("User: " + user);
            System.out.println("Tentative de connexion en cours (timeout 5s)...");

            DriverManager.setLoginTimeout(5);
            Class.forName("oracle.jdbc.OracleDriver");
            Connection conn = DriverManager.getConnection(url, user, pass);
            System.out.println(">>> SUCCES : Connexion a la base Oracle etablie avec succes ! <<<");
            conn.close();
        } catch (Exception e) {
            System.out.println(">>> ECHEC DE CONNEXION <<<");
            System.out.println("Message: " + e.getMessage());
        }
    }
}
