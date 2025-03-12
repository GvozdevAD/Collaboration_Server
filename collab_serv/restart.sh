#!/bin/bash
sleep 10
ring hazelcast --instance hcdev service stop
ring elasticsearch --instance esdev service stop
ring cs --instance csdev service stop

sleep 15


ring hazelcast --instance hcdev service start
sleep 1
ring elasticsearch --instance esdev service start
sleep 1
ring cs --instance csdev service start