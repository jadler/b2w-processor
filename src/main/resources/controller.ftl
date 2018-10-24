<#if package?? && package != "">
package ${package};

</#if>
import ${import};
import io.swagger.annotations.ApiOperation;
import java.util.Collection;
import javax.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.domain.ExampleMatcher.GenericPropertyMatcher;
import org.springframework.data.domain.ExampleMatcher.StringMatcher;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
@RequestMapping("/${"${inClass}"?lower_case}")
@ApiOperation("Operations belonging to the ${"${inClass}"?lower_case} entity")
public class ${outClass} {

    @Autowired
    protected MongoRepository<${inClass}, String> repository;

    @ApiOperation("Retrieve all ${"${inClass}"?lower_case}")
    @GetMapping({"", "/"})
    public Collection<${inClass}> list() {
        return repository.findAll();
    }

    @ApiOperation("Insert a new ${"${inClass}"?lower_case} entity")
    @PostMapping({"/"})
    public ${inClass} create(@Valid @RequestBody ${inClass} c) {
        return repository.save(c);
    }

    @ApiOperation("Update an ${"${inClass}"?lower_case} given its id")
    @PutMapping({"/id/{id}"})
    public ${inClass} modify(@PathVariable("id") String id, @Valid @RequestBody ${inClass} c) {
        c.setId(id);
        return repository.save(c);
    }

    @ApiOperation("Delete an ${"${inClass}"?lower_case} given its id")
    @DeleteMapping({"/id/{id}"})
    public void delete(@PathVariable String id) {
        repository.delete(repository.findById(id).get());
    }

<#if elements??>
<#list elements as element>
    @ApiOperation("Retrieve a ${"${inClass}"?lower_case} given its ${element.getSimpleName()}")
    @GetMapping(value = {"/${element.getSimpleName()}/{${element.getSimpleName()}}"})
    public ${inClass} getBy${"${element.getSimpleName()}"?capitalize}(@PathVariable("${element.getSimpleName()}") ${element.asType()} value) {
        ${inClass} c = new ${inClass}();
        c.set${"${element.getSimpleName()}"?capitalize}(value);
        
        GenericPropertyMatcher property;
        property = GenericPropertyMatcher.of(StringMatcher.EXACT);

        ExampleMatcher matcher = ExampleMatcher.matching()
                .withIgnoreCase()
                .withMatcher("${element.getSimpleName()}", property);
        
        return repository.findOne(Example.of(c, matcher)).get();
    }

</#list>
</#if>
}