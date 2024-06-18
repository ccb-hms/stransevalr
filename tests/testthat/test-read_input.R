test_that('error on numeric', {
    expect_error(read_input(5))
})

test_that('error on wrong colnames', {
    expect_error(read_input(data.frame(question = "blah",
                                       Response = "blah",
                                       model1   = "blah")))
})

test_that('no error on right colnames', {
    expect_equal(read_input(data.frame(question = "blah",
                                       answer   = "blah",
                                       model1   = "blah")),
                 data.table::data.table(question = "blah",
                                        answer   = "blah",
                                        model1   = "blah"))
})
