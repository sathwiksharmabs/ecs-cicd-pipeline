package cloud.sathwik.ecscicdapp;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/users")
public class UserController {

    @GetMapping
    public List<Map<String, String>> getUsers() {
        return List.of(
                Map.of("id", "1", "name", "John"),
                Map.of("id", "2", "name", "Alice")
        );
    }

    @PostMapping
    public Map<String, String> createUser(@RequestBody Map<String, String> user) {
        return Map.of(
                "message", "User created",
                "name", user.get("name")
        );
    }
}