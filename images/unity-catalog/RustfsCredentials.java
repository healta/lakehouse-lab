import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.unitycatalog.server.service.credential.CredentialContext;
import io.unitycatalog.server.service.credential.aws.AwsCredentialGenerator;
import io.unitycatalog.server.service.credential.aws.AwsPolicyGenerator;
import java.util.Iterator;
import java.util.UUID;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sts.StsClient;
import software.amazon.awssdk.services.sts.model.Credentials;

/**
 * Same as Unity Catalog's own generator (one-hour keys limited to one table), minus the part of the
 * policy about KMS encryption, which RustFS refuses. Address and keys come from AWS_* variables.
 */
public class RustfsCredentials implements AwsCredentialGenerator {
  private static final String ROLE = "arn:aws:iam::000000000000:role/lakehouse";
  private static final ObjectMapper JSON = new ObjectMapper();
  private final StsClient sts = StsClient.create();

  @Override
  public Credentials generate(CredentialContext context) {
    String policy = withoutKms(AwsPolicyGenerator.generatePolicy(
        context.getPrivileges(), context.getLocations(), ROLE, Region.US_EAST_1));
    return sts.assumeRole(request -> request
            .roleArn(ROLE)
            .roleSessionName("uc-" + UUID.randomUUID())
            .policy(policy)
            .durationSeconds(3600))
        .credentials();
  }

  private static String withoutKms(String policy) {
    try {
      JsonNode root = JSON.readTree(policy);
      Iterator<JsonNode> statements = root.get("Statement").elements();
      while (statements.hasNext()) {
        if (statements.next().get("Action").get(0).asText().startsWith("kms:")) {
          statements.remove();
        }
      }
      return JSON.writeValueAsString(root);
    } catch (java.io.IOException e) {
      throw new java.io.UncheckedIOException(e);
    }
  }
}
