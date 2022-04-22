//
//  DefineMarco.h
//
//
//  Created by Hongzhi Zhao on 2019/3/19.
//


/**
 * \@onExit defines some code to be executed when the current scope exits. The
 * code must be enclosed in braces and terminated with a semicolon, and will be
 * executed regardless of how the scope is exited, including from exceptions,
 * \c goto, \c return, \c break, and \c continue.
 *
 * Provided code will go into a block to be executed later. Keep this in mind as
 * it pertains to memory management, restrictions on assignment, etc. Because
 * the code is used within a block, \c return is a legal (though perhaps
 * confusing) way to exit the cleanup block early.
 *
 * Multiple \@onExit statements in the same scope are executed in reverse
 * lexical order. This helps when pairing resource acquisition with \@onExit
 * statements, as it guarantees teardown in the opposite order of acquisition.
 *
 * @note This statement cannot be used within scopes defined without braces
 * (like a one line \c if). In practice, this is not an issue, since \@onExit is
 * a useless construct in such a case anyways.
 
 * @onExit 常用于函数作用于结束的时候去指定一段指定代码。
 函数作用域结束特指 goto/return/break/continue 触发的作用域结束
 使用前 =>
     NSRecursiveLock *aLock = [[NSRecursiveLock alloc] init];
     [aLock lock];
     // 这里
     //     有
     //        100多万行
     [aLock unlock]; // 看到这儿的时候早忘了和哪个lock对应着了
 使用后 =>
    NSRecursiveLock *aLock = [[NSRecursiveLock alloc] init];
     [aLock lock];
     onExit {
     [aLock unlock]; // 妈妈再也不用担心我忘写后半段了
     };
     // 这里
     //    爱多少行
     //           就多少行
 关于 CleanUp的黑魔法可以参考 https://blog.sunnyxx.com/2014/09/15/objc-attribute-cleanup/
 */
#define wmOnExit \
    wmkit_keywordify \
    __strong wmkit_cleanupBlock_t wmkit_meta_concat(wmkit_exitBlock_, __LINE__) __attribute__((cleanup(wmkit_executeCleanupBlock), unused)) = ^

/**
 * Creates \c __weak shadow variables for each of the variables provided as
 * arguments, which can later be made strong again with #strongify.
 *
 * This is typically used to weakly reference variables in a block, but then
 * ensure that the variables stay alive during the actual execution of the block
 * (if they were live upon entry).
 *
 * See #strongify for an example of usage.
 */
#define wmWeakify(...) \
    wmkit_keywordify \
    wmkit_meta_foreach_cxt(wmkit_weakify_,, __weak, __VA_ARGS__)

/**
 * Like #weakify, but uses \c __unsafe_unretained instead, for targets or
 * classes that do not support weak references.
 */
#define wmUnsafeify(...) \
    wmkit_keywordify \
    wmkit_meta_foreach_cxt(wmkit_weakify_,, __unsafe_unretained, __VA_ARGS__)

/**
 * Strongly references each of the variables provided as arguments, which must
 * have previously been passed to #weakify.
 *
 * The strong references created will shadow the original variable names, such
 * that the original names can be used without issue (and a significantly
 * reduced risk of retain cycles) in the current scope.
 *
 * @code
 
 id foo = [[NSObject alloc] init];
 id bar = [[NSObject alloc] init];
 
 @weakify(foo, bar);
 
 // this block will not keep 'foo' or 'bar' alive
 BOOL (^matchesFooOrBar)(id) = ^ BOOL (id obj){
 // but now, upon entry, 'foo' and 'bar' will stay alive until the block has
 // finished executing
 @strongify(foo, bar);
 
 return [foo isEqual:obj] || [bar isEqual:obj];
 };
 
 * @endcode
 */
#define wmStrongify(...) \
    wmkit_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
    wmkit_meta_foreach(wmkit_strongify_,, __VA_ARGS__) \
_Pragma("clang diagnostic pop")

/*** implementation details follow ***/
typedef void (^wmkit_cleanupBlock_t)(void);

static inline void wmkit_executeCleanupBlock (__strong wmkit_cleanupBlock_t *block) {
    (*block)();
}

#define wmkit_weakify_(INDEX, CONTEXT, VAR) \
    CONTEXT __typeof__(VAR) wmkit_meta_concat(VAR, _weak_) = (VAR);

#define wmkit_strongify_(INDEX, VAR) \
    __strong __typeof__(VAR) VAR = wmkit_meta_concat(VAR, _weak_);


#if DEBUG
#define wmkit_keywordify autoreleasepool {}
#else
#define wmkit_keywordify try {} @catch (...) {}
#endif

/**
 * Macros for metaprogramming
 * ExtendedC
 *
 * Copyright (C) 2012 Justin Spahr-Summers
 * Released under the MIT license
 */

/**
 * Executes one or more expressions (which may have a void type, such as a call
 * to a function that returns no value) and always returns true.
 */
#define wmkit_meta_exprify(...) \
((__VA_ARGS__), true)

/**
 * Returns a string representation of VALUE after full macro expansion.
 */
#define wmkit_meta_stringify(VALUE) \
wmkit_meta_stringify_(VALUE)

/**
 * Returns A and B concatenated after full macro expansion.
 */
#define wmkit_meta_concat(A, B) \
wmkit_meta_concat_(A, B)

/**
 * Returns the Nth variadic argument (starting from zero). At least
 * N + 1 variadic arguments must be given. N must be between zero and twenty,
 * inclusive.
 */
#define wmkit_meta_at(N, ...) \
wmkit_meta_concat(wmkit_meta_at, N)(__VA_ARGS__)

/**
 * Returns the number of arguments (up to twenty) provided to the macro. At
 * least one argument must be provided.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define wmkit_meta_argcount(...) \
wmkit_meta_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

/**
 * Identical to #wmkit_meta_foreach_cxt, except that no CONTEXT argument is
 * given. Only the index and current argument will thus be passed to MACRO.
 */
#define wmkit_meta_foreach(MACRO, SEP, ...) \
wmkit_meta_foreach_cxt(wmkit_meta_foreach_iter, SEP, MACRO, __VA_ARGS__)

/**
 * For each consecutive variadic argument (up to twenty), MACRO is passed the
 * zero-based index of the current argument, CONTEXT, and then the argument
 * itself. The results of adjoining invocations of MACRO are then separated by
 * SEP.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define wmkit_meta_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
wmkit_meta_concat(wmkit_meta_foreach_cxt, wmkit_meta_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

/**
 * Identical to #wmkit_meta_foreach_cxt. This can be used when the former would
 * fail due to recursive macro expansion.
 */
#define wmkit_meta_foreach_cxt_recursive(MACRO, SEP, CONTEXT, ...) \
wmkit_meta_concat(wmkit_meta_foreach_cxt_recursive, wmkit_meta_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

/**
 * In consecutive order, appends each variadic argument (up to twenty) onto
 * BASE. The resulting concatenations are then separated by SEP.
 *
 * This is primarily useful to manipulate a list of macro invocations into instead
 * invoking a different, possibly related macro.
 */
#define wmkit_meta_foreach_concat(BASE, SEP, ...) \
wmkit_meta_foreach_cxt(wmkit_meta_foreach_concat_iter, SEP, BASE, __VA_ARGS__)

/**
 * Iterates COUNT times, each time invoking MACRO with the current index
 * (starting at zero) and CONTEXT. The results of adjoining invocations of MACRO
 * are then separated by SEP.
 *
 * COUNT must be an integer between zero and twenty, inclusive.
 */
#define wmkit_meta_for_cxt(COUNT, MACRO, SEP, CONTEXT) \
wmkit_meta_concat(wmkit_meta_for_cxt, COUNT)(MACRO, SEP, CONTEXT)

/**
 * Returns the first argument given. At least one argument must be provided.
 *
 * This is useful when implementing a variadic macro, where you may have only
 * one variadic argument, but no way to retrieve it (for example, because \c ...
 * always needs to match at least one argument).
 *
 * @code
 
 #define varmacro(...) \
 wmkit_meta_head(__VA_ARGS__)
 
 * @endcode
 */
#define wmkit_meta_head(...) \
wmkit_meta_head_(__VA_ARGS__, 0)

/**
 * Returns every argument except the first. At least two arguments must be
 * provided.
 */
#define wmkit_meta_tail(...) \
wmkit_meta_tail_(__VA_ARGS__)

/**
 * Returns the first N (up to twenty) variadic arguments as a new argument list.
 * At least N variadic arguments must be provided.
 */
#define wmkit_meta_take(N, ...) \
wmkit_meta_concat(wmkit_meta_take, N)(__VA_ARGS__)

/**
 * Removes the first N (up to twenty) variadic arguments from the given argument
 * list. At least N variadic arguments must be provided.
 */
#define wmkit_meta_drop(N, ...) \
wmkit_meta_concat(wmkit_meta_drop, N)(__VA_ARGS__)

/**
 * Decrements VAL, which must be a number between zero and twenty, inclusive.
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define wmkit_meta_dec(VAL) \
wmkit_meta_at(VAL, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)

/**
 * Increments VAL, which must be a number between zero and twenty, inclusive.
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define wmkit_meta_inc(VAL) \
wmkit_meta_at(VAL, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21)

/**
 * If A is equal to B, the next argument list is expanded; otherwise, the
 * argument list after that is expanded. A and B must be numbers between zero
 * and twenty, inclusive. Additionally, B must be greater than or equal to A.
 *
 * @code
 
 // expands to true
 wmkit_meta_if_eq(0, 0)(true)(false)
 
 // expands to false
 wmkit_meta_if_eq(0, 1)(true)(false)
 
 * @endcode
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define wmkit_meta_if_eq(A, B) \
wmkit_meta_concat(wmkit_meta_if_eq, A)(B)

/**
 * Identical to #wmkit_meta_if_eq. This can be used when the former would fail
 * due to recursive macro expansion.
 */
#define wmkit_meta_if_eq_recursive(A, B) \
wmkit_meta_concat(wmkit_meta_if_eq_recursive, A)(B)

/**
 * Returns 1 if N is an even number, or 0 otherwise. N must be between zero and
 * twenty, inclusive.
 *
 * For the purposes of this test, zero is considered even.
 */
#define wmkit_meta_is_even(N) \
wmkit_meta_at(N, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1)

/**
 * Returns the logical NOT of B, which must be the number zero or one.
 */
#define wmkit_meta_not(B) \
wmkit_meta_at(B, 1, 0)

// IMPLEMENTATION DETAILS FOLLOW!
// Do not write code that depends on anything below this line.
#define wmkit_meta_stringify_(VALUE) # VALUE
#define wmkit_meta_concat_(A, B) A ## B
#define wmkit_meta_foreach_iter(INDEX, MACRO, ARG) MACRO(INDEX, ARG)
#define wmkit_meta_head_(FIRST, ...) FIRST
#define wmkit_meta_tail_(FIRST, ...) __VA_ARGS__
#define wmkit_meta_consume_(...)
#define wmkit_meta_expand_(...) __VA_ARGS__

// implemented from scratch so that wmkit_meta_concat() doesn't end up nesting
#define wmkit_meta_foreach_concat_iter(INDEX, BASE, ARG) wmkit_meta_foreach_concat_iter_(BASE, ARG)
#define wmkit_meta_foreach_concat_iter_(BASE, ARG) BASE ## ARG

// wmkit_meta_at expansions
#define wmkit_meta_at0(...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at1(_0, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at2(_0, _1, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at3(_0, _1, _2, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at4(_0, _1, _2, _3, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at5(_0, _1, _2, _3, _4, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at6(_0, _1, _2, _3, _4, _5, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at7(_0, _1, _2, _3, _4, _5, _6, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) wmkit_meta_head(__VA_ARGS__)

// wmkit_meta_foreach_cxt expansions
#define wmkit_meta_foreach_cxt0(MACRO, SEP, CONTEXT)
#define wmkit_meta_foreach_cxt1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define wmkit_meta_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
wmkit_meta_foreach_cxt1(MACRO, SEP, CONTEXT, _0) \
SEP \
MACRO(1, CONTEXT, _1)

#define wmkit_meta_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
wmkit_meta_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
SEP \
MACRO(2, CONTEXT, _2)

#define wmkit_meta_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
wmkit_meta_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
SEP \
MACRO(3, CONTEXT, _3)

#define wmkit_meta_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
wmkit_meta_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
SEP \
MACRO(4, CONTEXT, _4)

#define wmkit_meta_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
wmkit_meta_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
SEP \
MACRO(5, CONTEXT, _5)

#define wmkit_meta_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
wmkit_meta_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
SEP \
MACRO(6, CONTEXT, _6)

#define wmkit_meta_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
wmkit_meta_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
SEP \
MACRO(7, CONTEXT, _7)

#define wmkit_meta_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
wmkit_meta_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
SEP \
MACRO(8, CONTEXT, _8)

#define wmkit_meta_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
wmkit_meta_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
SEP \
MACRO(9, CONTEXT, _9)

#define wmkit_meta_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
wmkit_meta_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
SEP \
MACRO(10, CONTEXT, _10)

#define wmkit_meta_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
wmkit_meta_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
SEP \
MACRO(11, CONTEXT, _11)

#define wmkit_meta_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
wmkit_meta_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
SEP \
MACRO(12, CONTEXT, _12)

#define wmkit_meta_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
wmkit_meta_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
SEP \
MACRO(13, CONTEXT, _13)

#define wmkit_meta_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
wmkit_meta_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
SEP \
MACRO(14, CONTEXT, _14)

#define wmkit_meta_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
wmkit_meta_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
SEP \
MACRO(15, CONTEXT, _15)

#define wmkit_meta_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
wmkit_meta_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
SEP \
MACRO(16, CONTEXT, _16)

#define wmkit_meta_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
wmkit_meta_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
SEP \
MACRO(17, CONTEXT, _17)

#define wmkit_meta_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
wmkit_meta_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
SEP \
MACRO(18, CONTEXT, _18)

#define wmkit_meta_foreach_cxt20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
wmkit_meta_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
SEP \
MACRO(19, CONTEXT, _19)

// wmkit_meta_foreach_cxt_recursive expansions
#define wmkit_meta_foreach_cxt_recursive0(MACRO, SEP, CONTEXT)
#define wmkit_meta_foreach_cxt_recursive1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define wmkit_meta_foreach_cxt_recursive2(MACRO, SEP, CONTEXT, _0, _1) \
wmkit_meta_foreach_cxt_recursive1(MACRO, SEP, CONTEXT, _0) \
SEP \
MACRO(1, CONTEXT, _1)

#define wmkit_meta_foreach_cxt_recursive3(MACRO, SEP, CONTEXT, _0, _1, _2) \
wmkit_meta_foreach_cxt_recursive2(MACRO, SEP, CONTEXT, _0, _1) \
SEP \
MACRO(2, CONTEXT, _2)

#define wmkit_meta_foreach_cxt_recursive4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
wmkit_meta_foreach_cxt_recursive3(MACRO, SEP, CONTEXT, _0, _1, _2) \
SEP \
MACRO(3, CONTEXT, _3)

#define wmkit_meta_foreach_cxt_recursive5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
wmkit_meta_foreach_cxt_recursive4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
SEP \
MACRO(4, CONTEXT, _4)

#define wmkit_meta_foreach_cxt_recursive6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
wmkit_meta_foreach_cxt_recursive5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
SEP \
MACRO(5, CONTEXT, _5)

#define wmkit_meta_foreach_cxt_recursive7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
wmkit_meta_foreach_cxt_recursive6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
SEP \
MACRO(6, CONTEXT, _6)

#define wmkit_meta_foreach_cxt_recursive8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
wmkit_meta_foreach_cxt_recursive7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
SEP \
MACRO(7, CONTEXT, _7)

#define wmkit_meta_foreach_cxt_recursive9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
wmkit_meta_foreach_cxt_recursive8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
SEP \
MACRO(8, CONTEXT, _8)

#define wmkit_meta_foreach_cxt_recursive10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
wmkit_meta_foreach_cxt_recursive9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
SEP \
MACRO(9, CONTEXT, _9)

#define wmkit_meta_foreach_cxt_recursive11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
wmkit_meta_foreach_cxt_recursive10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
SEP \
MACRO(10, CONTEXT, _10)

#define wmkit_meta_foreach_cxt_recursive12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
wmkit_meta_foreach_cxt_recursive11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
SEP \
MACRO(11, CONTEXT, _11)

#define wmkit_meta_foreach_cxt_recursive13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
wmkit_meta_foreach_cxt_recursive12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
SEP \
MACRO(12, CONTEXT, _12)

#define wmkit_meta_foreach_cxt_recursive14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
wmkit_meta_foreach_cxt_recursive13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
SEP \
MACRO(13, CONTEXT, _13)

#define wmkit_meta_foreach_cxt_recursive15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
wmkit_meta_foreach_cxt_recursive14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
SEP \
MACRO(14, CONTEXT, _14)

#define wmkit_meta_foreach_cxt_recursive16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
wmkit_meta_foreach_cxt_recursive15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
SEP \
MACRO(15, CONTEXT, _15)

#define wmkit_meta_foreach_cxt_recursive17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
wmkit_meta_foreach_cxt_recursive16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
SEP \
MACRO(16, CONTEXT, _16)

#define wmkit_meta_foreach_cxt_recursive18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
wmkit_meta_foreach_cxt_recursive17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
SEP \
MACRO(17, CONTEXT, _17)

#define wmkit_meta_foreach_cxt_recursive19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
wmkit_meta_foreach_cxt_recursive18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
SEP \
MACRO(18, CONTEXT, _18)

#define wmkit_meta_foreach_cxt_recursive20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
wmkit_meta_foreach_cxt_recursive19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
SEP \
MACRO(19, CONTEXT, _19)

// wmkit_meta_for_cxt expansions
#define wmkit_meta_for_cxt0(MACRO, SEP, CONTEXT)
#define wmkit_meta_for_cxt1(MACRO, SEP, CONTEXT) MACRO(0, CONTEXT)

#define wmkit_meta_for_cxt2(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt1(MACRO, SEP, CONTEXT) \
SEP \
MACRO(1, CONTEXT)

#define wmkit_meta_for_cxt3(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt2(MACRO, SEP, CONTEXT) \
SEP \
MACRO(2, CONTEXT)

#define wmkit_meta_for_cxt4(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt3(MACRO, SEP, CONTEXT) \
SEP \
MACRO(3, CONTEXT)

#define wmkit_meta_for_cxt5(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt4(MACRO, SEP, CONTEXT) \
SEP \
MACRO(4, CONTEXT)

#define wmkit_meta_for_cxt6(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt5(MACRO, SEP, CONTEXT) \
SEP \
MACRO(5, CONTEXT)

#define wmkit_meta_for_cxt7(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt6(MACRO, SEP, CONTEXT) \
SEP \
MACRO(6, CONTEXT)

#define wmkit_meta_for_cxt8(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt7(MACRO, SEP, CONTEXT) \
SEP \
MACRO(7, CONTEXT)

#define wmkit_meta_for_cxt9(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt8(MACRO, SEP, CONTEXT) \
SEP \
MACRO(8, CONTEXT)

#define wmkit_meta_for_cxt10(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt9(MACRO, SEP, CONTEXT) \
SEP \
MACRO(9, CONTEXT)

#define wmkit_meta_for_cxt11(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt10(MACRO, SEP, CONTEXT) \
SEP \
MACRO(10, CONTEXT)

#define wmkit_meta_for_cxt12(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt11(MACRO, SEP, CONTEXT) \
SEP \
MACRO(11, CONTEXT)

#define wmkit_meta_for_cxt13(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt12(MACRO, SEP, CONTEXT) \
SEP \
MACRO(12, CONTEXT)

#define wmkit_meta_for_cxt14(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt13(MACRO, SEP, CONTEXT) \
SEP \
MACRO(13, CONTEXT)

#define wmkit_meta_for_cxt15(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt14(MACRO, SEP, CONTEXT) \
SEP \
MACRO(14, CONTEXT)

#define wmkit_meta_for_cxt16(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt15(MACRO, SEP, CONTEXT) \
SEP \
MACRO(15, CONTEXT)

#define wmkit_meta_for_cxt17(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt16(MACRO, SEP, CONTEXT) \
SEP \
MACRO(16, CONTEXT)

#define wmkit_meta_for_cxt18(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt17(MACRO, SEP, CONTEXT) \
SEP \
MACRO(17, CONTEXT)

#define wmkit_meta_for_cxt19(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt18(MACRO, SEP, CONTEXT) \
SEP \
MACRO(18, CONTEXT)

#define wmkit_meta_for_cxt20(MACRO, SEP, CONTEXT) \
wmkit_meta_for_cxt19(MACRO, SEP, CONTEXT) \
SEP \
MACRO(19, CONTEXT)

// wmkit_meta_if_eq expansions
#define wmkit_meta_if_eq0(VALUE) \
wmkit_meta_concat(wmkit_meta_if_eq0_, VALUE)

#define wmkit_meta_if_eq0_0(...) __VA_ARGS__ wmkit_meta_consume_
#define wmkit_meta_if_eq0_1(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_2(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_3(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_4(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_5(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_6(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_7(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_8(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_9(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_10(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_11(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_12(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_13(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_14(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_15(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_16(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_17(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_18(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_19(...) wmkit_meta_expand_
#define wmkit_meta_if_eq0_20(...) wmkit_meta_expand_

#define wmkit_meta_if_eq1(VALUE) wmkit_meta_if_eq0(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq2(VALUE) wmkit_meta_if_eq1(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq3(VALUE) wmkit_meta_if_eq2(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq4(VALUE) wmkit_meta_if_eq3(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq5(VALUE) wmkit_meta_if_eq4(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq6(VALUE) wmkit_meta_if_eq5(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq7(VALUE) wmkit_meta_if_eq6(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq8(VALUE) wmkit_meta_if_eq7(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq9(VALUE) wmkit_meta_if_eq8(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq10(VALUE) wmkit_meta_if_eq9(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq11(VALUE) wmkit_meta_if_eq10(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq12(VALUE) wmkit_meta_if_eq11(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq13(VALUE) wmkit_meta_if_eq12(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq14(VALUE) wmkit_meta_if_eq13(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq15(VALUE) wmkit_meta_if_eq14(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq16(VALUE) wmkit_meta_if_eq15(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq17(VALUE) wmkit_meta_if_eq16(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq18(VALUE) wmkit_meta_if_eq17(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq19(VALUE) wmkit_meta_if_eq18(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq20(VALUE) wmkit_meta_if_eq19(wmkit_meta_dec(VALUE))

// wmkit_meta_if_eq_recursive expansions
#define wmkit_meta_if_eq_recursive0(VALUE) \
wmkit_meta_concat(wmkit_meta_if_eq_recursive0_, VALUE)

#define wmkit_meta_if_eq_recursive0_0(...) __VA_ARGS__ wmkit_meta_consume_
#define wmkit_meta_if_eq_recursive0_1(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_2(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_3(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_4(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_5(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_6(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_7(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_8(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_9(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_10(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_11(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_12(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_13(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_14(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_15(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_16(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_17(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_18(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_19(...) wmkit_meta_expand_
#define wmkit_meta_if_eq_recursive0_20(...) wmkit_meta_expand_

#define wmkit_meta_if_eq_recursive1(VALUE) wmkit_meta_if_eq_recursive0(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive2(VALUE) wmkit_meta_if_eq_recursive1(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive3(VALUE) wmkit_meta_if_eq_recursive2(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive4(VALUE) wmkit_meta_if_eq_recursive3(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive5(VALUE) wmkit_meta_if_eq_recursive4(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive6(VALUE) wmkit_meta_if_eq_recursive5(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive7(VALUE) wmkit_meta_if_eq_recursive6(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive8(VALUE) wmkit_meta_if_eq_recursive7(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive9(VALUE) wmkit_meta_if_eq_recursive8(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive10(VALUE) wmkit_meta_if_eq_recursive9(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive11(VALUE) wmkit_meta_if_eq_recursive10(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive12(VALUE) wmkit_meta_if_eq_recursive11(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive13(VALUE) wmkit_meta_if_eq_recursive12(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive14(VALUE) wmkit_meta_if_eq_recursive13(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive15(VALUE) wmkit_meta_if_eq_recursive14(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive16(VALUE) wmkit_meta_if_eq_recursive15(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive17(VALUE) wmkit_meta_if_eq_recursive16(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive18(VALUE) wmkit_meta_if_eq_recursive17(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive19(VALUE) wmkit_meta_if_eq_recursive18(wmkit_meta_dec(VALUE))
#define wmkit_meta_if_eq_recursive20(VALUE) wmkit_meta_if_eq_recursive19(wmkit_meta_dec(VALUE))

// wmkit_meta_take expansions
#define wmkit_meta_take0(...)
#define wmkit_meta_take1(...) wmkit_meta_head(__VA_ARGS__)
#define wmkit_meta_take2(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take1(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take3(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take2(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take4(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take3(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take5(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take4(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take6(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take5(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take7(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take6(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take8(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take7(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take9(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take8(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take10(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take9(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take11(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take10(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take12(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take11(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take13(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take12(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take14(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take13(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take15(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take14(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take16(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take15(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take17(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take16(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take18(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take17(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take19(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take18(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_take20(...) wmkit_meta_head(__VA_ARGS__), wmkit_meta_take19(wmkit_meta_tail(__VA_ARGS__))

// wmkit_meta_drop expansions
#define wmkit_meta_drop0(...) __VA_ARGS__
#define wmkit_meta_drop1(...) wmkit_meta_tail(__VA_ARGS__)
#define wmkit_meta_drop2(...) wmkit_meta_drop1(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop3(...) wmkit_meta_drop2(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop4(...) wmkit_meta_drop3(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop5(...) wmkit_meta_drop4(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop6(...) wmkit_meta_drop5(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop7(...) wmkit_meta_drop6(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop8(...) wmkit_meta_drop7(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop9(...) wmkit_meta_drop8(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop10(...) wmkit_meta_drop9(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop11(...) wmkit_meta_drop10(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop12(...) wmkit_meta_drop11(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop13(...) wmkit_meta_drop12(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop14(...) wmkit_meta_drop13(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop15(...) wmkit_meta_drop14(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop16(...) wmkit_meta_drop15(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop17(...) wmkit_meta_drop16(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop18(...) wmkit_meta_drop17(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop19(...) wmkit_meta_drop18(wmkit_meta_tail(__VA_ARGS__))
#define wmkit_meta_drop20(...) wmkit_meta_drop19(wmkit_meta_tail(__VA_ARGS__))
