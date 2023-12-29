# Terraform Modules

Stores the reusable bits of a configuration.

## `load_balancer`

Exposes an endpoint that will load balance requests across a set of RPC nodes. Sets up:

* Instance groups for each zone with RPC nodes
* Health checks to use for the instances
* Backend service that links the instance groups with the checks
* URL map that just forwards all requests to the instances
* Google-managed HTTPS certificate
* HTTPS proxy that binds the URL map to the certificate
* Static IP for the load balancer
* Load balancer that binds the HTTPS proxy to the static IP

Requires a list of RPC Instances to attach to, and a list of domains to bind the HTTPS certificate to.

## `minimal_service_accounts`

Create a service account with the minimal possible bindings required to attach to a GCE instance but still write
logs and metrics. Passed into the node module.

## `node`

Creates a GCE instance, in either the 'validator' configuration, or the 'rpc' configuration.

Creates a PD for each node. Optionally creates a static IP, if the node is a validator.

A startup script automatically mounts the attached PD on boot, and configures it to remount automatically.

## `safe_service_accounts`

Deletes the GCE default service account (security best practice).

## `vpc`

Configures a VPC, with subnets in each region, and firewall rules.

The firewall rules:

* Prevent ingress from anything other than Google IAP on port 22
* Allow ingress to validators on the Avalanche P2P port from any IP
* Allow ingress to rpc nodes from Google load balancers on port 80

# TODO

Lot of things could be improved here.

## Health Check

The healthcheck doesn't take into account the response from avalanchego. It should only mark a node alive if it returns
a valid JSON response that all subnets are bootstrapped.

## URL Map

Should probably only forward `/rpc` / `ws` / `health`. Right now just forwards any request to the RPC node.

## Blockscout

Probably need to update this to support optional blockscout, too.

## Avalanche Subnet module

Could probably extract all this into an `avalanche_subnet` module instead of having so much stuff in each project.
