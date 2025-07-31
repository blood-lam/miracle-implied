import boto3, os

ec2 = boto3.client("ec2")
allocation_id = os.environ["ALLOCATION_ID"]
subnet_id = os.environ["PUBLIC_SUBNET_ID"]
route_table_id = os.environ["PRIVATE_ROUTE_TABLE_ID"]


def upsert_route_to_nat(route_table_id, nat_id):
    # Check if route exists
    route_exists = False
    response = ec2.describe_route_tables(RouteTableIds=[route_table_id])
    for rt in response["RouteTables"]:
        for route in rt["Routes"]:
            if route.get("DestinationCidrBlock") == "0.0.0.0/0":
                route_exists = True
                break

    if route_exists:
        ec2.replace_route(
            RouteTableId=route_table_id,
            DestinationCidrBlock="0.0.0.0/0",
            NatGatewayId=nat_id,
        )
        print("Replaced existing route to NAT Gateway.")
    else:
        ec2.create_route(
            RouteTableId=route_table_id,
            DestinationCidrBlock="0.0.0.0/0",
            NatGatewayId=nat_id,
        )
        print("Created new route to NAT Gateway.")


def handler(event, context):
    action = event.get("action", "OFF").upper()
    print(f"NAT Gateway toggle request: {action}")

    # Find current NAT Gateway
    response = ec2.describe_nat_gateways(
        Filters=[
            {"Name": "subnet-id", "Values": [subnet_id]},
            {"Name": "state", "Values": ["available", "pending"]},
        ]
    )
    nat_gateways = response["NatGateways"]
    existing_nat = nat_gateways[0] if nat_gateways else None

    if action == "ON" and not existing_nat:
        print("Creating NAT Gateway...")
        create_response = ec2.create_nat_gateway(
            SubnetId=subnet_id,
            AllocationId=allocation_id,
            TagSpecifications=[
                {
                    "ResourceType": "natgateway",
                    "Tags": [
                        {"Key": "Name", "Value": "MiracleImpliedNATGateway"},
                    ],
                }
            ],
        )
        nat_id = create_response["NatGateway"]["NatGatewayId"]
        print(f"NAT Gateway created with ID: {nat_id}")

        waiter = ec2.get_waiter("nat_gateway_available")
        waiter.wait(NatGatewayIds=[nat_id])

        upsert_route_to_nat(route_table_id, nat_id)
        print("NAT Gateway enabled.")

    elif action == "OFF" and existing_nat:
        nat_id = existing_nat["NatGatewayId"]
        print(f"Deleting NAT Gateway {nat_id}")
        ec2.delete_nat_gateway(NatGatewayId=nat_id)

        # Safe to call delete_route — if the route doesn't exist, this won't raise an error
        try:
            ec2.delete_route(
                RouteTableId=route_table_id, DestinationCidrBlock="0.0.0.0/0"
            )
            print("Route to NAT Gateway deleted.")
        except ec2.exceptions.ClientError as e:
            print(f"No route to delete or error occurred: {e}")
        print("NAT Gateway deleted.")
    else:
        print("No action needed or invalid state.")
