<#if package?? && package != "">
package ${package};

</#if>
import ${import};
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.domain.ExampleMatcher.GenericPropertyMatcher;
import org.springframework.data.domain.ExampleMatcher.StringMatcher;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/${"${inClass}"?lower_case}")
@ApiOperation("Operations belonging to the ${"${inClass}"?lower_case} entity")
public class ${outClass} extends Controller<${inClass}> {

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