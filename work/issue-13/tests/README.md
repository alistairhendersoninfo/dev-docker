# n8n Testing Suite

This directory contains all tests for the n8n automation server implementation.

## Test Categories

### Unit Tests
- Individual workflow component testing
- Configuration validation
- Webhook endpoint testing

### Integration Tests
- Docker API integration
- Database connectivity
- DNS management integration
- Traefik configuration testing

### End-to-End Tests
- Complete workflow execution
- Multi-service integration
- Performance testing

## Test Files

- `test-n8n-deployment.sh` - Container deployment and startup tests
- `test-webhook-api.py` - Webhook endpoint functional tests
- `integration/` - Integration test suites

## Running Tests

```bash
# Run all tests
./run-tests.sh

# Run specific test category
./test-n8n-deployment.sh
python test-webhook-api.py
```
