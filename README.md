# Processor
Projeto java que gerar classes "Repository" e "Controller" em um projeto spring a partir de anotações nas classes de modelo.

## Instalação

Clone este repositório para sua máquina local com `git clone https://github.com/jadler/processor.git` e execute o comando:

    mvn clean install
    
## Uso

Para criar classes de repositório para os modelos é necessário adicionar a anotação `@GenerateRepository` e para as classes de controle adicionar a anotação `@GenerateController`. O projeto também permite criar consultas nas classes de controle para os campos das classe de modelo adicionando a anotação `@MappedProperty`.

```java
package br.com.jadler.models;

import br.com.jadler.annotation.MappedProperty;
import br.com.jadler.annotation.GenerateRepository;
import br.com.jadler.annotation.GenerateController;
import org.springframework.data.annotation.Id;

@GenerateRepository
@GenerateController
public class Persons {
    
    @Id
    @MappedProperty
    private String id;
    
    @MappedProperty
    private String name;
    
    @MappedProperty
    private Integer age;
    
    // getters and setters

}
```

#### PersonsController

```java
package br.com.jadler.controller;

import ...

@RestController
@RequestMapping("/persons")
@ApiOperation("...")
public class PersonsController {

    @Autowired
    protected MongoRepository<Persons, String> repository;

    @ApiOperation("...")
    @GetMapping({"", "/"})
    public Collection<Persons> list() {
        //...
    }

    @ApiOperation("...")
    @PostMapping({"/"})
    public Persons create(@Valid @RequestBody Persons c) {
        //...
    }

    @ApiOperation("...")
    @PutMapping({"/id/{id}"})
    public Persons modify(@PathVariable("id") String id, @Valid @RequestBody Persons c) {
        //...
    }

    @ApiOperation("...")
    @DeleteMapping({"/id/{id}"})
    public void delete(@PathVariable String id) {
        //...
    }

    @ApiOperation("...")
    @GetMapping(value = {"/id/{id}"})
    public Persons getById(@PathVariable("id") java.lang.String value) {
        //...
    }

    @ApiOperation("...")
    @GetMapping(value = {"/name/{name}"})
    public Persons getByName(@PathVariable("name") java.lang.String value) {
        //...
    }
    
    @ApiOperation("...")
    @GetMapping(value = {"/age/{age}"})
    public Persons getByAge(@PathVariable("age") java.lang.Integer value) {
        //...
    }
}
```

#### PersonsRepository

```java
package br.com.jadler.repository;

import ...

public interface PersonsRepository extends MongoRepository<Persons, String> {
}
```
