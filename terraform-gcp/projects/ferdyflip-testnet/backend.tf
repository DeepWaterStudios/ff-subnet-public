terraform {
  backend "gcs" {
    bucket = "ferdyflip-testnet-tf"
    prefix = "state"
  }
}
