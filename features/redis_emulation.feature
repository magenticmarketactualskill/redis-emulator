Feature: Redis Emulation with Solid Cache
  As a Rails developer
  I want to use Redis Emulator as a drop-in replacement for Redis
  So that I can use Solid Cache as my persistence layer

  Scenario: Basic key-value operations
    Given I have a Redis Emulator client
    When I set "mykey" to "myvalue"
    Then I should be able to get "myvalue" from "mykey"

  Scenario: Delete operations
    Given I have a Redis Emulator client
    And I set "key1" to "value1"
    And I set "key2" to "value2"
    When I delete "key1"
    Then "key1" should not exist
    And "key2" should exist

  Scenario: Increment operations
    Given I have a Redis Emulator client
    When I increment "counter"
    Then "counter" should equal 1
    When I increment "counter"
    Then "counter" should equal 2

  Scenario: Multiple key operations
    Given I have a Redis Emulator client
    When I set multiple keys:
      | key   | value   |
      | key1  | value1  |
      | key2  | value2  |
      | key3  | value3  |
    Then getting multiple keys "key1,key2,key3" should return "value1,value2,value3"

  Scenario: Expiration operations
    Given I have a Redis Emulator client
    When I set "tempkey" to "tempvalue" with expiration of 60 seconds
    Then "tempkey" should exist
