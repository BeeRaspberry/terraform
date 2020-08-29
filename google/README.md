# Google Cloud Instructions

This code leverages modules built by Google.

This code builds a private cluster with a bastion fronting the cluster. 

Options include creating a Google Cloud SQL database, or creating one within the cluster. If a Cloud SQL instance is created the code creates random passwords for a 'root' and 'api' password which is posted into Google's Secret Management system. These can then be access by other systems; aka: such as a CD pipeline.

## Variable Definitions
