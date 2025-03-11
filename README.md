# About this project

I have modified slightly the original task description to tie better with a potential payment system. Instead of "content" the actual consumers and senders work with "invoices" which have corresponding pdf file - the "content".

The Sender and Consumer APIs have a dummy authentication available by passing a header "Authorization" with "sender ID" or "consumer ID" values.

Possibly the "content" should be uploaded using another endpoint with multipart http request, so that we can control better the allowed request size for the regular API endpoints and the file upload endpoint, but this is out of the scope for the project at the moment.

# Setup

1. Run `docker compose up` to start the postgres database used to persist the invoice's metadata. Run `mix setup` to fetch dependencies and create the dev database.
2. Run `iex -S mix phx.server` to start interactive shell with the application running.

# Dockerfile

The project has a Dockerfile which will package it in a docker container. You can try it out by running `docker compose -f ./docker-compose-prod.yml up`, but before that run the steps from "Setup" so that the project database is available.

# Example requests

Create an invoice entry and upload a corresponding file at once:
```
content=`cat priv/helloworld.pdf | base64`
curl -v -H 'Content-type: application/json' -H 'Authorization: sender 1' --data "{\"invoice\": {\"receiver_id\": 2, \"file_type\": \"application/pdf\", \"content\": \"$content\"}}"  localhost:4000/api/sender/invoices
```

Query content by sender id for the authenticated consumer:
```
curl -v  -H 'Content-type: application/json' -H 'Authorization: consumer 2' localhost:4000/api/consumer/invoices/sender/1
```

Pay invoice if it is payable:
```
curl -X POST -H 'Authorization: consumer 2' -v localhost:4000/api/consumer/invoices/<invoice_id>/pay
```

Download the file attached to the invoice:
```
curl -H 'Authorization: consumer 2' -v localhost:4000/api/consumer/invoices/<invoice_id>/file > file.pdf
```

# Performance test

You can test the application performance with:
```
ab -p priv/ab_sample.txt -T application/json -H 'Authorization: sender 1' -c 10 -n 10000 http://127.0.0.1:4000/api/sender/invoices
```

And view the performance results in the Live Dashboard http://localhost:4000/dev/dashboard/metrics?nav=phoenix

# Suggested approach to host the service

The invoice service could be packaged in a Docker image and deployed inside Kubernetes cluster (e.g. GKE). The service could be horizontally scaled with a load balancer which distributes the requests among all instances. For file storage it could be used a cloud based storage solution like GC Storage and the database can be provided as GC SQL Postgres instance (with or without HA).

The service itself interacts mostly with the database and the file storage so it does not justify any more complex setup than this (no node communication or anything like that).

In addition some integration with Open Telemetry enabled services will be useful, like tracing with Jaeger, log aggregation in GC Logging or Grafana with Loki. Service metrics can be collected using Prometheus and displayed in Grafana. Log or metrics based alerts can be created via Grafana or GC Monitoring. Sentry could be used for easier observability of common errors and prioritization of their fixing.

# Design decisions

The application was scaffolded using the mix tasks from Phoenix without html, js, assets and follows the default way of making Phoenix application with Ecto. One thing I'd like to change is to run validation of the input in the controller and be able to return directly a client error ("Bad request") in case the input is invalid. At the moment this validation is done by Ecto in the changeset much "deeper" in the control flow of the actions, but there is no corresponding validation for the "content" that is sent with the action to create an invoice and instead I have to support two validation mechanisms - Ecto and my own.