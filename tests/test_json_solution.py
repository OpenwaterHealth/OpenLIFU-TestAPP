import json
import numpy as np
from openlifu.bf.pulse import Pulse 
from openlifu.bf.sequence import Sequence
from openlifu.geo import Point
from openlifu.plan.solution import Solution

# Example JSON string (this could also be loaded from a file)
json_string = '''{
  "id": "solution",
  "name": "Solution",
  "protocol_id": "example_protocol",
  "transducer_id": "example_transducer",
  "delays": [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  ],
  "apodizations": [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  ],
  "pulse": {
    "frequency": 500000,
    "amplitude": 1,
    "duration": 0.00002
  },
  "sequence": {
    "pulse_interval": 0.1,
    "pulse_count": 10,
    "pulse_train_interval": 1,
    "pulse_train_count": 1
  },
  "target": {
    "position": [0, 0, 30],
    "units": "mm"
  },
  "foci": [
    {
      "position": [0, 0, 30],
      "units": "mm"
    }
  ],
  "approved": true
}'''

# Load JSON data into a dictionary
data = json.loads(json_string)

# Create Pulse object
pulse_data = data["pulse"]
pulse = Pulse(
    frequency=pulse_data["frequency"],
    amplitude=pulse_data["amplitude"],
    duration=pulse_data["duration"]
)

# Create Sequence object
sequence_data = data["sequence"]
sequence = Sequence(
    pulse_interval=sequence_data["pulse_interval"],
    pulse_count=sequence_data["pulse_count"],
    pulse_train_interval=sequence_data["pulse_train_interval"],
    pulse_train_count=sequence_data["pulse_train_count"]
)

# Create Point object for target
target_data = data["target"]
target = Point(
    position=tuple(target_data["position"]),
    units=target_data["units"]
)

# Create list of Point objects for foci
foci = [Point(position=tuple(focus["position"]), units=focus["units"]) 
        for focus in data["foci"]]

# Convert delays and apodizations to numpy arrays
delays = np.array(data["delays"])
apodizations = np.array(data["apodizations"])

# Create the Solution object
solution = Solution(
    id=data["id"],
    name=data["name"],
    protocol_id=data["protocol_id"],
    transducer_id=data["transducer_id"],
    delays=delays,
    apodizations=apodizations,
    pulse=pulse,
    sequence=sequence,
    target=target,
    foci=foci,
    approved=data["approved"]
)

