variable "buckets"{
    type = list(string)
    default = [ "12345meghnathbucket","54321meghnathbucket","kiuhwskfquy63t8763"]
}

variable "buckets1"{
    type = set(string)
    default = [ "12345meghnathbucket","54321meghnathbucket","kiuhwskfquy63t8763"]
}