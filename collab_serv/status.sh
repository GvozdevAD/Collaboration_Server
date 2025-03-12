echo  "[INFO] Hazelcast status - $(ring hazelcast --instance hcdev service status)"
echo  "[INFO] Elasticsearch status - $(ring elasticsearch --instance esdev service status)"
echo  "[INFO] CollabServer status - $(ring cs --instance csdev service status)"